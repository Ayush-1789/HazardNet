import 'package:equatable/equatable.dart';

/// Events for Camera BLoC
abstract class CameraEvent extends Equatable {
  const CameraEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class StartDetection extends CameraEvent {}

class StopDetection extends CameraEvent {}

class CaptureImage extends CameraEvent {}

class SwitchCamera extends CameraEvent {}

class StartRecording extends CameraEvent {}

class StopRecording extends CameraEvent {}

class ProcessFrame extends CameraEvent {
  final dynamic imageData; // CameraImage or XFile
  
  const ProcessFrame(this.imageData);
  
  @override
  List<Object?> get props => [imageData];
}

class DisposeCameraEvent extends CameraEvent {}

class RequestCameraPermission extends CameraEvent {}
