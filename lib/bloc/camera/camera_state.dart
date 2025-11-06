import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

/// States for Camera BLoC
abstract class CameraState extends Equatable {
  const CameraState();
  
  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  final List<CameraDescription> cameras;
  final bool isDetecting;
  final bool isRecording;
  final int framesProcessed;
  final double fps;
  
  const CameraReady({
    required this.controller,
    required this.cameras,
    this.isDetecting = false,
    this.isRecording = false,
    this.framesProcessed = 0,
    this.fps = 0.0,
  });
  
  @override
  List<Object> get props => [controller, cameras, isDetecting, isRecording, framesProcessed, fps];
  
  CameraReady copyWith({
    CameraController? controller,
    List<CameraDescription>? cameras,
    bool? isDetecting,
    bool? isRecording,
    int? framesProcessed,
    double? fps,
  }) {
    return CameraReady(
      controller: controller ?? this.controller,
      cameras: cameras ?? this.cameras,
      isDetecting: isDetecting ?? this.isDetecting,
      isRecording: isRecording ?? this.isRecording,
      framesProcessed: framesProcessed ?? this.framesProcessed,
      fps: fps ?? this.fps,
    );
  }
}

class CameraDetecting extends CameraState {
  final int framesProcessed;
  final double fps;
  
  const CameraDetecting({
    this.framesProcessed = 0,
    this.fps = 0.0,
  });
  
  @override
  List<Object> get props => [framesProcessed, fps];
}

class CameraImageCaptured extends CameraState {
  final String imagePath;
  
  const CameraImageCaptured(this.imagePath);
  
  @override
  List<Object> get props => [imagePath];
}

class CameraError extends CameraState {
  final String message;
  
  const CameraError(this.message);
  
  @override
  List<Object> get props => [message];
}

class CameraPermissionDenied extends CameraState {}
