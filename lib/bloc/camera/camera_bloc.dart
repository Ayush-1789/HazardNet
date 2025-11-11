import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:event_safety_app/bloc/camera/camera_event.dart';
import 'package:event_safety_app/bloc/camera/camera_state.dart';
import 'package:event_safety_app/core/constants/model_config.dart';
import 'package:event_safety_app/data/services/detector_isolate.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';
import 'package:event_safety_app/data/services/captured_hazard_store.dart';
import 'package:event_safety_app/models/captured_hazard_model.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final TFLiteService _tfliteService;
  final CapturedHazardStore _hazardStore;
  final List<CameraDescription> _availableCameras;

  CameraController? _controller;
  int _currentCameraIndex = 0;
  bool _isDetecting = false;
  bool _imageStreamActive = false;

  DetectorIsolate? _detectorIsolate;
  StreamSubscription<DetectionPacket>? _detectorSubscription;
  final Uuid _uuid = const Uuid();
  int _frameCount = 0;
  bool _captureInProgress = false;
  DateTime? _lastFpsUpdate;
  int _framesProcessedSinceLastUpdate = 0;
  int _latestDetectionSequence = -1;
  bool _allowRealtimeDetections = false;
  bool _loggedDetectorBackpressure = false;

  CameraBloc({
    required TFLiteService tfliteService,
    required CapturedHazardStore hazardStore,
    required List<CameraDescription> availableCameras,
  })  : _tfliteService = tfliteService,
        _hazardStore = hazardStore,
        _availableCameras = availableCameras,
        super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartDetection>(_onStartDetection);
    on<StopDetection>(_onStopDetection);
    on<ProcessFrame>(_onProcessFrame, transformer: droppable());
    on<CaptureImage>(_onCaptureImage);
    on<SwitchCamera>(_onSwitchCamera);
    on<DeleteCapturedHazard>(_onDeleteCapturedHazard);
    on<DisposeCameraEvent>(_onDisposeCamera);
  }

  Future<void> _onInitializeCamera(InitializeCamera event, Emitter<CameraState> emit) async {
    try {
      emit(CameraLoading());
      final description = _availableCameras[_currentCameraIndex];
      _controller = CameraController(
        description,
        ResolutionPreset.low,  // Prioritize FPS for analysis stream
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();
      final savedHazards = await _hazardStore.loadHazards();
      emit(
        CameraReady(
          controller: _controller!,
          cameras: _availableCameras,
          isDetecting: false,
          capturedHazards: savedHazards,
        ),
      );
    } catch (e) {
      emit(CameraError('Failed to initialize camera: ${e.toString()}'));
    }
  }

  Future<void> _onStartDetection(StartDetection event, Emitter<CameraState> emit) async {
    if (state is! CameraReady) return;
    try {
      await _ensureDetectorInitialized();
      _isDetecting = true;
      _allowRealtimeDetections = true;
      _frameCount = 0;
      _framesProcessedSinceLastUpdate = 0;
      _lastFpsUpdate = DateTime.now();
      _latestDetectionSequence = -1;

      await _startImageStream();
      if (state is CameraReady) {
        emit((state as CameraReady).copyWith(
          isDetecting: true,
          fps: 0.0,
          framesProcessed: 0,
          detections: const [],
        ));
      }
    } catch (e) {
      emit(CameraError('Failed to start detection: ${e.toString()}'));
    }
  }

  Future<void> _onStopDetection(StopDetection event, Emitter<CameraState> emit) async {
    _isDetecting = false;
    _allowRealtimeDetections = false;
    _latestDetectionSequence = -1;
    if (_imageStreamActive) {
      await _controller?.stopImageStream();
      _imageStreamActive = false;
    }
    _frameCount = 0;
    _framesProcessedSinceLastUpdate = 0;
    _lastFpsUpdate = null;
    
    if (state is CameraReady) {
      emit((state as CameraReady).copyWith(
        isDetecting: false,
        fps: 0.0,
        framesProcessed: 0,
        detections: const [],
      ));
    }
  }

  Future<void> _onProcessFrame(ProcessFrame event, Emitter<CameraState> emit) async {
    if (!_isDetecting || !_imageStreamActive) return;

  _frameCount += event.frameSpan;
  _framesProcessedSinceLastUpdate += event.frameSpan;
    
    final now = DateTime.now();
    final capturedAt = event.capturedAt;
    
    // Update FPS display every 500ms
    if (_lastFpsUpdate == null || now.difference(_lastFpsUpdate!).inMilliseconds >= 500) {
      final fps = _lastFpsUpdate == null 
          ? 0.0
          : (_framesProcessedSinceLastUpdate * 1000) / now.difference(_lastFpsUpdate!).inMilliseconds;
      
      if (state is CameraReady && !isClosed) {
        emit((state as CameraReady).copyWith(
          fps: fps,
          framesProcessed: _frameCount,
        ));
      }
      
      _lastFpsUpdate = now;
      _framesProcessedSinceLastUpdate = 0;
    }
    
    final jpegBytes = event.imageData as Uint8List;
    _sendFrameToDetector(jpegBytes, capturedAt);
  }


  Future<void> _onDeleteCapturedHazard(DeleteCapturedHazard event, Emitter<CameraState> emit) async {
    try {
      await _hazardStore.deleteHazard(event.hazardId);
      if (state is CameraReady && !isClosed) {
        final currentState = state as CameraReady;
        emit(currentState.copyWith(capturedHazards: currentState.capturedHazards.where((h) => h.id != event.hazardId).toList()));
      }
    } catch (e) {
      // Silently fail - don't update state with error
    }
  }

  Future<void> _onCaptureImage(CaptureImage event, Emitter<CameraState> emit) async {
    if (state is! CameraReady || _controller == null) return;
    if (_captureInProgress) return; // prevent re-entrancy / duplicate captures
    _captureInProgress = true;
    try {
      final image = await _controller!.takePicture();
      String finalImagePath = image.path;
      final currentState = state as CameraReady;
      final imageFile = File(image.path);
      Uint8List savedBytes = await imageFile.readAsBytes();

      if (currentState.detections.isNotEmpty) {
        try {
          final annotatedBytes = _tfliteService.drawDetectionsOnJpeg(
            savedBytes,
            currentState.detections,
          );

          if (annotatedBytes != null) {
            savedBytes = annotatedBytes;
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final directory = await getApplicationDocumentsDirectory();
            final annotatedPath = '${directory.path}/annotated_$timestamp.jpg';

            final annotatedFile = File(annotatedPath);
            await annotatedFile.writeAsBytes(savedBytes);

            finalImagePath = annotatedPath;
            debugPrint(
              '📸 Saved annotated image with ${currentState.detections.length} detection(s): $annotatedPath',
            );
          }
        } catch (e) {
          debugPrint('❌ Failed to create annotated image, using original: $e');
        }
      }

      CapturedHazardModel? savedHazard;
      if (currentState.detections.isNotEmpty) {
        try {
          final capturedDetections = currentState.detections
              .map((d) => CapturedDetectionModel.fromDetection(d))
              .toList();
          final hazard = CapturedHazardModel(
            id: _uuid.v4(),
            timestamp: DateTime.now(),
            imagePath: '',
            detections: capturedDetections,
            sensorSnapshot: const {},
          );
          savedHazard = await _hazardStore.saveHazard(
            hazard: hazard,
            imageBytes: savedBytes,
          );
        } catch (e) {
          debugPrint('❌ Failed to persist captured hazard: $e');
        }
      }

      if (state is CameraReady && !isClosed) {
        final currentStateAfter = state as CameraReady;
        emit(
          currentStateAfter.copyWith(
            capturedImagePath: finalImagePath,
            capturedHazards: savedHazard != null
                ? [...currentStateAfter.capturedHazards, savedHazard]
                : currentStateAfter.capturedHazards,
            lastCapturedHazardId: savedHazard?.id,
            clearLastCapturedHazardId: savedHazard == null,
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to capture image: $e');
    } finally {
      _captureInProgress = false;
    }
  }

  Future<void> _onSwitchCamera(SwitchCamera event, Emitter<CameraState> emit) async {
    if (state is! CameraReady || _availableCameras.length < 2) return;
    
    try {
      // Save detection state
      final wasDetecting = _isDetecting;
      
      // Stop detection cleanly first
      if (_isDetecting) {
        _isDetecting = false;
        _allowRealtimeDetections = false;
        if (_imageStreamActive) {
          await _controller?.stopImageStream();
          _imageStreamActive = false;
        }
        _frameCount = 0;
        _framesProcessedSinceLastUpdate = 0;
        _lastFpsUpdate = null;
      }
      
      // Dispose old controller
      final oldController = _controller;
      _controller = null;
      await oldController?.dispose();
      
      // Switch camera index
      _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
      
      // Create new controller
      final description = _availableCameras[_currentCameraIndex];
      final newController = CameraController(
        description,
        ResolutionPreset.low,  // Prioritize FPS for analysis stream
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await newController.initialize();
      _controller = newController;
      
      // Update state with new controller
      if (state is CameraReady && !isClosed) {
        // Clear any transient captured image path so UI doesn't re-show the last capture
        emit((state as CameraReady).copyWith(
          controller: newController,
          isDetecting: false,
          fps: 0.0,
          framesProcessed: 0,
          clearCapturedImage: true,
        ));
      }
      
      // Restart detection if it was active
      if (wasDetecting && !isClosed) {
        add(StartDetection());
      }
    } catch (e) {
      debugPrint('Failed to switch camera: $e');
      if (!isClosed) {
        emit(CameraError('Failed to switch camera: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDisposeCamera(DisposeCameraEvent event, Emitter<CameraState> emit) async {
    await _shutdownController();
    await _disposeDetector();
    if (!isClosed) {
      emit(CameraInitial());
    }
  }

  Future<void> _startImageStream() async {
    if (_imageStreamActive || _controller == null) return;
    try {
      final int skip = ModelConfig.FRAME_SKIP <= 1 ? 1 : ModelConfig.FRAME_SKIP;
      int framesSinceLastEmission = 0;

      await _controller!.startImageStream((image) {
        framesSinceLastEmission++;

        if (framesSinceLastEmission < skip) {
          return; // Only process every Nth frame to control workload
        }

        if (!_allowRealtimeDetections || !_detectorHasCapacity) {
          framesSinceLastEmission = 0;
          return;
        }

        try {
          final jpeg = _tfliteService.convertCameraImageToJpeg(
            image,
            forBuffering: true,
          );

          if (jpeg != null) {
            final capturedAt = DateTime.now();
            add(
              ProcessFrame(
                jpeg,
                frameSpan: framesSinceLastEmission,
                capturedAt: capturedAt,
              ),
            );
          }
        } catch (e) {
          debugPrint('Frame conversion error: $e');
        } finally {
          framesSinceLastEmission = 0;
        }
      });
      _imageStreamActive = true;
    } catch (e) {
      _imageStreamActive = false;
      rethrow;
    }
  }

  Future<void> _ensureDetectorInitialized() async {
    if (_detectorIsolate != null) return;
    try {
      _detectorIsolate = await DetectorIsolate.spawn(
        maxInflight: ModelConfig.MAX_INFLIGHT_DETECTIONS,
      );
      _detectorSubscription = _detectorIsolate!.results.listen(
        _handleDetectorPacket,
        onError: (error, stackTrace) {
          debugPrint('Detector isolate error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start detector isolate: $e');
      rethrow;
    }
  }

  void _sendFrameToDetector(Uint8List jpegBytes, DateTime timestamp) {
    if (!_allowRealtimeDetections) return;
    final detector = _detectorIsolate;
    if (detector == null) return;
    final accepted = detector.enqueueFrame(jpegBytes, timestamp: timestamp);
    if (!accepted && !_loggedDetectorBackpressure) {
      debugPrint('⚠️ Detector busy - dropping frames to preserve FPS');
      _loggedDetectorBackpressure = true;
    } else if (accepted) {
      _loggedDetectorBackpressure = false;
    }
  }

  bool get _detectorHasCapacity =>
      _detectorIsolate?.hasCapacity ?? false;

  void _handleDetectorPacket(DetectionPacket packet) {
    if (!_isDetecting || !_allowRealtimeDetections) return;
    if (packet.sequenceId <= _latestDetectionSequence) return;
    _latestDetectionSequence = packet.sequenceId;

    final filtered = packet.detections
        .where((d) => d.confidence >= ModelConfig.CONFIDENCE_THRESHOLD)
        .toList(growable: false);

    if (state is CameraReady && !isClosed) {
      emit((state as CameraReady).copyWith(detections: filtered));
    }
  }

  Future<void> _disposeDetector() async {
    await _detectorSubscription?.cancel();
    _detectorSubscription = null;
    if (_detectorIsolate != null) {
      await _detectorIsolate!.dispose();
      _detectorIsolate = null;
    }
    _latestDetectionSequence = -1;
    _allowRealtimeDetections = false;
  }

  Future<void> _shutdownController() async {
    try {
      if (_imageStreamActive) await _controller?.stopImageStream();
      _imageStreamActive = false;
      await _controller?.dispose();
      _controller = null;
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _shutdownController();
    await _disposeDetector();
    return super.close();
  }
}
