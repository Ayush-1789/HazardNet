import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';
import 'package:event_safety_app/models/captured_hazard_model.dart';

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
  final List<Detection> detections;
  final String? capturedImagePath;
  final List<CapturedHazardModel> capturedHazards;
  final String? lastCapturedHazardId;

  const CameraReady({
    required this.controller,
    required this.cameras,
    this.isDetecting = false,
    this.isRecording = false,
    this.framesProcessed = 0,
    this.fps = 0.0,
    this.detections = const [],
    this.capturedImagePath,
    this.capturedHazards = const [],
    this.lastCapturedHazardId,
  });

  @override
  List<Object?> get props => [
        controller,
        cameras,
        isDetecting,
        isRecording,
        framesProcessed,
        fps,
        detections,
        capturedImagePath,
        capturedHazards,
        lastCapturedHazardId,
      ];

  CameraReady copyWith({
    CameraController? controller,
    List<CameraDescription>? cameras,
    bool? isDetecting,
    bool? isRecording,
    int? framesProcessed,
    double? fps,
    List<Detection>? detections,
    String? capturedImagePath,
    bool clearCapturedImage = false,
    List<CapturedHazardModel>? capturedHazards,
    String? lastCapturedHazardId,
    bool clearLastCapturedHazardId = false,
  }) {
    return CameraReady(
      controller: controller ?? this.controller,
      cameras: cameras ?? this.cameras,
      isDetecting: isDetecting ?? this.isDetecting,
      isRecording: isRecording ?? this.isRecording,
      framesProcessed: framesProcessed ?? this.framesProcessed,
      fps: fps ?? this.fps,
      detections: detections ?? this.detections,
      capturedImagePath:
          clearCapturedImage ? null : (capturedImagePath ?? this.capturedImagePath),
      capturedHazards: capturedHazards ?? this.capturedHazards,
      lastCapturedHazardId: clearLastCapturedHazardId
          ? null
          : (lastCapturedHazardId ?? this.lastCapturedHazardId),
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

class CameraError extends CameraState {
  final String message;

  const CameraError(this.message);

  @override
  List<Object> get props => [message];
}

class CameraPermissionDenied extends CameraState {}
