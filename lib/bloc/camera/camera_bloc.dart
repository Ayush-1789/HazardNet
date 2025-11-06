import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_event.dart';
import 'camera_state.dart';

/// BLoC for managing camera operations and frame processing
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;
  bool _isDetecting = false;
  bool _isProcessingFrame = false; // Prevent buffer overflow
  int _framesProcessed = 0;
  DateTime? _lastFrameTime;
  
  CameraBloc() : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartDetection>(_onStartDetection);
    on<StopDetection>(_onStopDetection);
    on<CaptureImage>(_onCaptureImage);
    on<SwitchCamera>(_onSwitchCamera);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<ProcessFrame>(_onProcessFrame);
    on<DisposeCameraEvent>(_onDisposeCamera);
    on<RequestCameraPermission>(_onRequestCameraPermission);
  }
  
  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      emit(CameraLoading());
      
      // Check camera permission
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          emit(CameraPermissionDenied());
          return;
        }
      }
      
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        emit(const CameraError('No cameras available'));
        return;
      }
      
      // Initialize camera controller with back camera
      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController!.initialize();
      
      // Set flash mode to off by default
      await _cameraController!.setFlashMode(FlashMode.off);
      
      emit(CameraReady(
        controller: _cameraController!,
        cameras: _cameras!,
      ));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }
  
  Future<void> _onStartDetection(
    StartDetection event,
    Emitter<CameraState> emit,
  ) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      emit(const CameraError('Camera not initialized'));
      return;
    }
    
    _isDetecting = true;
    _framesProcessed = 0;
    _lastFrameTime = DateTime.now();
    
    // Start image stream for real-time detection
    await _cameraController!.startImageStream((CameraImage image) {
      // Skip frame if still processing previous frame (prevents buffer overflow)
      if (_isDetecting && !_isProcessingFrame) {
        add(ProcessFrame(image));
      }
    });
    
    if (state is CameraReady) {
      final currentState = state as CameraReady;
      emit(currentState.copyWith(
        isDetecting: true,
      ));
    }
  }
  
  Future<void> _onStopDetection(
    StopDetection event,
    Emitter<CameraState> emit,
  ) async {
    _isDetecting = false;
    
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    
    if (state is CameraReady) {
      final currentState = state as CameraReady;
      emit(currentState.copyWith(
        isDetecting: false,
      ));
    }
  }
  
  Future<void> _onCaptureImage(
    CaptureImage event,
    Emitter<CameraState> emit,
  ) async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        emit(const CameraError('Camera not initialized'));
        return;
      }
      
      // Stop image stream if running
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      
      final image = await _cameraController!.takePicture();
      
      emit(CameraImageCaptured(image.path));
      
      // Resume detection if it was running
      if (_isDetecting) {
        add(StartDetection());
      }
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }
  
  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      if (_cameras == null || _cameras!.length < 2) {
        return;
      }
      
      // Dispose current controller
      await _cameraController?.dispose();
      
      // Switch to next camera
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
      
      // Initialize new controller
      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      
      emit(CameraReady(
        controller: _cameraController!,
        cameras: _cameras!,
      ));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }
  
  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<CameraState> emit,
  ) async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        return;
      }
      
      await _cameraController!.startVideoRecording();
      
      if (state is CameraReady) {
        final currentState = state as CameraReady;
        emit(currentState.copyWith(
          isRecording: true,
        ));
      }
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }
  
  Future<void> _onStopRecording(
    StopRecording event,
    Emitter<CameraState> emit,
  ) async {
    try {
      if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
        return;
      }
      
      final video = await _cameraController!.stopVideoRecording();
      
      if (state is CameraReady) {
        final currentState = state as CameraReady;
        emit(currentState.copyWith(
          isRecording: false,
        ));
      }
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }
  
  void _onProcessFrame(
    ProcessFrame event,
    Emitter<CameraState> emit,
  ) {
    // Skip if already processing
    if (_isProcessingFrame) return;
    
    _isProcessingFrame = true;
    
    try {
      // Calculate FPS
      _framesProcessed++;
      final now = DateTime.now();
      final fps = _lastFrameTime != null
          ? 1000 / now.difference(_lastFrameTime!).inMilliseconds
          : 0.0;
      _lastFrameTime = now;
      
      // TODO: Send frame to ML model API for hazard detection
      // This will be connected to the YOLO model API later
      
      // Update CameraReady state with stats
      if (state is CameraReady) {
        final currentState = state as CameraReady;
        emit(currentState.copyWith(
          framesProcessed: _framesProcessed,
          fps: fps,
        ));
      }
    } finally {
      _isProcessingFrame = false;
    }
  }
  
  Future<void> _onDisposeCamera(
    DisposeCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    _isDetecting = false;
    _isProcessingFrame = false;
    
    // Properly stop image stream before disposing
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      try {
        await _cameraController!.stopImageStream();
      } catch (e) {
        // Ignore errors during dispose
      }
    }
    
    await _cameraController?.dispose();
    _cameraController = null;
    emit(CameraInitial());
  }
  
  Future<void> _onRequestCameraPermission(
    RequestCameraPermission event,
    Emitter<CameraState> emit,
  ) async {
    final result = await Permission.camera.request();
    if (!result.isGranted) {
      emit(CameraPermissionDenied());
    }
  }
  
  @override
  Future<void> close() {
    _isDetecting = false;
    _isProcessingFrame = false;
    
    // Properly clean up camera resources
    if (_cameraController != null) {
      if (_cameraController!.value.isStreamingImages) {
        _cameraController!.stopImageStream().catchError((_) {});
      }
      _cameraController!.dispose();
    }
    
    return super.close();
  }
}
