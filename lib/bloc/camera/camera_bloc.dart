import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:event_safety_app/bloc/camera/camera_event.dart';
import 'package:event_safety_app/bloc/camera/camera_state.dart';
import 'package:event_safety_app/bloc/location/location_bloc.dart';
import 'package:event_safety_app/core/constants/model_config.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';
import 'package:event_safety_app/data/services/captured_hazard_store.dart';
import 'package:event_safety_app/data/services/gyro_monitor_service.dart';
import 'package:event_safety_app/models/captured_hazard_model.dart';
import 'package:event_safety_app/models/sensor_data_model.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final TFLiteService _tfliteService;
  final CapturedHazardStore _hazardStore;
  final LocationBloc _locationBloc;
  final GyroMonitorService _gyroMonitor;
  final List<CameraDescription> _availableCameras;

  CameraController? _controller;
  int _currentCameraIndex = 0;
  bool _isDetecting = false;
  bool _imageStreamActive = false;

  final List<_BufferedFrame> _frameBuffer = [];
  StreamSubscription<SensorDataModel>? _gyroSubscription;
  final Uuid _uuid = const Uuid();
  int _frameCount = 0;
  bool _isProcessingGyro = false;
  DateTime? _lastFpsUpdate;
  int _framesProcessedSinceLastUpdate = 0;

  CameraBloc({
    required TFLiteService tfliteService,
    required CapturedHazardStore hazardStore,
    required LocationBloc locationBloc,
    required GyroMonitorService gyroMonitor,
    required List<CameraDescription> availableCameras,
  })  : _tfliteService = tfliteService,
        _hazardStore = hazardStore,
        _locationBloc = locationBloc,
        _gyroMonitor = gyroMonitor,
        _availableCameras = availableCameras,
        super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartDetection>(_onStartDetection);
    on<StopDetection>(_onStopDetection);
    on<ProcessFrame>(_onProcessFrame, transformer: droppable());
    on<GyroImpactDetected>(_onGyroImpactDetected);
    on<LoadCapturedHazards>(_onLoadCapturedHazards);
    on<DeleteCapturedHazard>(_onDeleteCapturedHazard);
    on<DisposeCameraEvent>(_onDisposeCamera);
  }

  Future<void> _onInitializeCamera(InitializeCamera event, Emitter<CameraState> emit) async {
    try {
      emit(CameraLoading());
      await _ensureModelLoaded();
      final description = _availableCameras[_currentCameraIndex];
      _controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();
      emit(CameraReady(controller: _controller!, cameras: _availableCameras, isDetecting: false, capturedHazards: const []));
    } catch (e) {
      emit(CameraError('Failed to initialize camera: ${e.toString()}'));
    }
  }

  Future<void> _onStartDetection(StartDetection event, Emitter<CameraState> emit) async {
    if (state is! CameraReady) return;
    try {
      await _ensureModelLoaded();
      _isDetecting = true;
      _gyroMonitor.startMonitoring();
      _gyroSubscription = _gyroMonitor.impactStream.listen((sensorData) {
        add(GyroImpactDetected(sensorData));
      });
      await _startImageStream();
      if (state is CameraReady) {
        emit((state as CameraReady).copyWith(isDetecting: true));
      }
    } catch (e) {
      emit(CameraError('Failed to start detection: ${e.toString()}'));
    }
  }

  Future<void> _onStopDetection(StopDetection event, Emitter<CameraState> emit) async {
    _isDetecting = false;
    await _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _gyroMonitor.stopMonitoring();
    if (_imageStreamActive) {
      await _controller?.stopImageStream();
      _imageStreamActive = false;
    }
    _frameBuffer.clear();
    if (state is CameraReady) {
      emit((state as CameraReady).copyWith(isDetecting: false));
    }
  }

  Future<void> _onProcessFrame(ProcessFrame event, Emitter<CameraState> emit) async {
    if (!_isDetecting || !_imageStreamActive) return;
    
    _frameCount++;
    _framesProcessedSinceLastUpdate++;
    
    // Update FPS every second
    final now = DateTime.now();
    if (_lastFpsUpdate == null || now.difference(_lastFpsUpdate!).inMilliseconds >= 1000) {
      final fps = _lastFpsUpdate == null 
          ? 30.0 
          : (_framesProcessedSinceLastUpdate * 1000) / now.difference(_lastFpsUpdate!).inMilliseconds;
      
      if (state is CameraReady) {
        emit((state as CameraReady).copyWith(
          fps: fps,
          framesProcessed: _frameCount,
        ));
      }
      
      _lastFpsUpdate = now;
      _framesProcessedSinceLastUpdate = 0;
    }
    
    // Only process every 3rd frame to reduce CPU load and achieve 40+ FPS
    if (_frameCount % 3 != 0) return;
    
    try {
      // Convert to JPEG (fast, ~5-10ms)
      final jpegBytes = _tfliteService.convertCameraImageToJpeg(event.imageData);
      if (jpegBytes == null) return;
      
      _frameBuffer.add(_BufferedFrame(bytes: jpegBytes, timestamp: DateTime.now()));
      _pruneBuffer();
    } catch (_) {}
  }

  Future<void> _onGyroImpactDetected(GyroImpactDetected event, Emitter<CameraState> emit) async {
    if (!_isDetecting || state is! CameraReady || _isProcessingGyro) return;
    
    _isProcessingGyro = true;
    
    // Run detection asynchronously without blocking UI
    _processGyroDetection(event).then((_) {
      _isProcessingGyro = false;
    }).catchError((e) {
      debugPrint('Gyro detection error: $e');
      _isProcessingGyro = false;
    });
  }
  
  Future<void> _processGyroDetection(GyroImpactDetected event) async {
    final frames = _frameBuffer.toList(growable: false);
    if (frames.isEmpty) return;
    
    final int maxFrames = math.min(frames.length, ModelConfig.GYRO_ANALYSIS_MAX_FRAMES);
    final int step = math.max(1, frames.length ~/ maxFrames);
    
    int processed = 0;
    double bestConfidence = 0;
    List<Detection> bestDetections = const [];
    _BufferedFrame? bestFrame;
    
    // Process frames, yielding periodically to keep UI responsive
    for (int i = frames.length - 1; i >= 0 && processed < maxFrames; i -= step) {
      final frame = frames[i];
      
      // Run detection
      final detections = await _tfliteService.detectObjectsFromJpeg(frame.bytes);
      
      final filtered = detections.where((d) => d.confidence >= ModelConfig.GYRO_MIN_CONFIDENCE).toList();
      
      if (filtered.isNotEmpty) {
        final topDetection = filtered.reduce((a, b) => a.confidence >= b.confidence ? a : b);
        if (topDetection.confidence > bestConfidence) {
          bestConfidence = topDetection.confidence;
          bestDetections = filtered;
          bestFrame = frame;
        }
      }
      
      processed++;
      
      // Yield to event loop every 5 frames to keep UI responsive
      if (processed % 5 == 0) {
        await Future.delayed(const Duration(milliseconds: 1));
      }
    }
    
    if (bestFrame != null && bestDetections.isNotEmpty) {
      final capturedDetections = bestDetections.map((d) => CapturedDetectionModel.fromDetection(d)).toList();
      final hazard = CapturedHazardModel(
        id: _uuid.v4(), 
        timestamp: event.sensorData.timestamp, 
        imagePath: '', 
        detections: capturedDetections, 
        sensorSnapshot: event.sensorData.toJson()
      );
      
      final savedHazard = await _hazardStore.saveHazard(hazard: hazard, imageBytes: bestFrame.bytes);
      
      if (state is CameraReady) {
        final currentState = state as CameraReady;
        emit(currentState.copyWith(
          capturedHazards: [...currentState.capturedHazards, savedHazard], 
          lastCapturedHazardId: savedHazard.id
        ));
      }
    }
  }

  Future<void> _onLoadCapturedHazards(LoadCapturedHazards event, Emitter<CameraState> emit) async {
    try {
      final hazards = await _hazardStore.loadHazards();
      if (state is CameraReady) emit((state as CameraReady).copyWith(capturedHazards: hazards));
    } catch (e) {
      // Silently fail - don't update state with error
    }
  }

  Future<void> _onDeleteCapturedHazard(DeleteCapturedHazard event, Emitter<CameraState> emit) async {
    try {
      await _hazardStore.deleteHazard(event.hazardId);
      if (state is CameraReady) {
        final currentState = state as CameraReady;
        emit(currentState.copyWith(capturedHazards: currentState.capturedHazards.where((h) => h.id != event.hazardId).toList()));
      }
    } catch (e) {
      // Silently fail - don't update state with error
    }
  }

  Future<void> _onDisposeCamera(DisposeCameraEvent event, Emitter<CameraState> emit) async => await _shutdownController();

  Future<void> _startImageStream() async {
    if (_imageStreamActive || _controller == null) return;
    try {
      await _controller!.startImageStream((image) {
        // ignore: void_checks
        add(ProcessFrame(image));
      });
      _imageStreamActive = true;
    } catch (e) {
      _imageStreamActive = false;
      rethrow;
    }
  }

  Future<void> _ensureModelLoaded() async {
    if (!_tfliteService.isModelLoaded) await _tfliteService.loadModel();
  }

  void _pruneBuffer() {
    final cutoff = DateTime.now().subtract(Duration(seconds: ModelConfig.BUFFER_DURATION_SECONDS));
    _frameBuffer.removeWhere((f) => f.timestamp.isBefore(cutoff));
    while (_frameBuffer.length > ModelConfig.BUFFER_MAX_FRAMES) {
      _frameBuffer.removeAt(0);
    }
  }

  Future<void> _shutdownController() async {
    try {
      await _gyroSubscription?.cancel();
      _gyroSubscription = null;
      _gyroMonitor.stopMonitoring();
      if (_imageStreamActive) await _controller?.stopImageStream();
      _imageStreamActive = false;
      await _controller?.dispose();
      _controller = null;
      _frameBuffer.clear();
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _shutdownController();
    return super.close();
  }
}

class _BufferedFrame {
  final Uint8List bytes;
  final DateTime timestamp;
  _BufferedFrame({required this.bytes, required this.timestamp});
}
