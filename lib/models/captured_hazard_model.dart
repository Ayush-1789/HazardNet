import 'dart:convert';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';

/// Compact representation of a detection that can be serialized.
class CapturedDetectionModel extends Equatable {
  final String label;
  final double confidence;
  final Rect boundingBox; // Normalized coordinates

  const CapturedDetectionModel({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  factory CapturedDetectionModel.fromDetection(Detection detection) {
    return CapturedDetectionModel(
      label: detection.label,
      confidence: detection.confidence,
      boundingBox: detection.boundingBox,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'bounding_box': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
    };
  }

  factory CapturedDetectionModel.fromJson(Map<String, dynamic> json) {
    final box = json['bounding_box'] as Map<String, dynamic>;
    return CapturedDetectionModel(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBox: Rect.fromLTRB(
        (box['left'] as num).toDouble(),
        (box['top'] as num).toDouble(),
        (box['right'] as num).toDouble(),
        (box['bottom'] as num).toDouble(),
      ),
    );
  }

  @override
  List<Object?> get props => [label, confidence, boundingBox];
}

/// Data class representing a saved hazard capture.
class CapturedHazardModel extends Equatable {
  final String id;
  final DateTime timestamp;
  final String imagePath;
  final List<CapturedDetectionModel> detections;
  final Map<String, dynamic> sensorSnapshot;
  final Map<String, dynamic>? locationSnapshot;

  const CapturedHazardModel({
    required this.id,
    required this.timestamp,
    required this.imagePath,
    required this.detections,
    required this.sensorSnapshot,
    this.locationSnapshot,
  });

  CapturedHazardModel copyWith({
    String? imagePath,
    List<CapturedDetectionModel>? detections,
    Map<String, dynamic>? sensorSnapshot,
    Map<String, dynamic>? locationSnapshot,
  }) {
    return CapturedHazardModel(
      id: id,
      timestamp: timestamp,
      imagePath: imagePath ?? this.imagePath,
      detections: detections ?? this.detections,
      sensorSnapshot: sensorSnapshot ?? this.sensorSnapshot,
      locationSnapshot: locationSnapshot ?? this.locationSnapshot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'image_path': imagePath,
      'detections': detections.map((d) => d.toJson()).toList(),
      'sensor_snapshot': sensorSnapshot,
      'location_snapshot': locationSnapshot,
    };
  }

  factory CapturedHazardModel.fromJson(Map<String, dynamic> json) {
    final detectionsJson = json['detections'] as List<dynamic>?;
    return CapturedHazardModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['image_path'] as String,
      detections: detectionsJson != null
          ? detectionsJson
              .map((e) => CapturedDetectionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      sensorSnapshot: (json['sensor_snapshot'] as Map<String, dynamic>?) ?? const {},
      locationSnapshot: json['location_snapshot'] as Map<String, dynamic>?,
    );
  }

  String encode() => jsonEncode(toJson());

  static CapturedHazardModel decode(String source) =>
      CapturedHazardModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, timestamp, imagePath, detections, sensorSnapshot, locationSnapshot];
}
