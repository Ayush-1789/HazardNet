import 'package:equatable/equatable.dart';
import 'package:event_safety_app/models/sensor_data_model.dart';

/// Events for Camera BLoC
abstract class CameraEvent extends Equatable {
  const CameraEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class StartDetection extends CameraEvent {}

class StopDetection extends CameraEvent {}

class LoadCapturedHazards extends CameraEvent {}

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

class GyroImpactDetected extends CameraEvent {
  final SensorDataModel sensorData;

  const GyroImpactDetected(this.sensorData);

  @override
  List<Object?> get props => [sensorData];
}

class DeleteCapturedHazard extends CameraEvent {
  final String hazardId;

  const DeleteCapturedHazard(this.hazardId);

  @override
  List<Object?> get props => [hazardId];
}
