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

class ProcessFrame extends CameraEvent {
  final dynamic imageData; // CameraImage or pre-converted bytes
  final int frameSpan; // Number of stream frames represented by this event
  final DateTime capturedAt;

  ProcessFrame(
    this.imageData, {
    this.frameSpan = 1,
    DateTime? capturedAt,
  }) : capturedAt = capturedAt ?? DateTime.now();

  @override
  List<Object?> get props => [imageData, frameSpan, capturedAt];
}

class DisposeCameraEvent extends CameraEvent {}

class RequestCameraPermission extends CameraEvent {}

class DeleteCapturedHazard extends CameraEvent {
  final String hazardId;

  const DeleteCapturedHazard(this.hazardId);

  @override
  List<Object?> get props => [hazardId];
}
