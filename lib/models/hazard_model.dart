import 'package:equatable/equatable.dart';

/// Model representing a detected road hazard
class HazardModel extends Equatable {
  final String id;
  final String type; // pothole, speed_breaker, obstacle, etc.
  final double latitude;
  final double longitude;
  final String severity; // low, medium, high, critical
  final double confidence; // Detection confidence (0.0 - 1.0)
  final DateTime detectedAt;
  final String? imageUrl; // Blurred image stored in cloud
  final String? description;
  final int verificationCount; // Number of users who reported same hazard
  final bool isVerified;
  final Map<String, dynamic>? metadata; // Additional sensor data
  final String? lane; // Specific lane if detected
  final double? depth; // Estimated depth for potholes (from depth model)
  final String? reportedBy; // User ID who reported this hazard
  final String? reportedByName; // Name of the first user who reported
  
  const HazardModel({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.confidence,
    required this.detectedAt,
    this.imageUrl,
    this.description,
    this.verificationCount = 1,
    this.isVerified = false,
    this.metadata,
    this.lane,
    this.depth,
    this.reportedBy,
    this.reportedByName,
  });
  
  @override
  List<Object?> get props => [
    id,
    type,
    latitude,
    longitude,
    severity,
    confidence,
    detectedAt,
    imageUrl,
    description,
    verificationCount,
    isVerified,
    metadata,
    lane,
    depth,
    reportedBy,
    reportedByName,
  ];
  
  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
      'confidence': confidence,
      'detected_at': detectedAt.toIso8601String(),
      'image_url': imageUrl,
      'description': description,
      'verification_count': verificationCount,
      'is_verified': isVerified,
      'metadata': metadata,
      'lane': lane,
      'depth': depth,
      'reported_by': reportedBy,
      'reported_by_name': reportedByName,
    };
  }
  
  /// Create model from JSON
  factory HazardModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDetectedAt(dynamic value) {
      try {
        if (value == null) return DateTime.now();
        if (value is int) {
          // Might be seconds or milliseconds
          if (value > 1000000000000) {
            // looks like milliseconds
            return DateTime.fromMillisecondsSinceEpoch(value);
          }
          // assume seconds
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }

        if (value is double) {
          final v = value.toInt();
          if (v > 1000000000000) {
            return DateTime.fromMillisecondsSinceEpoch(v);
          }
          return DateTime.fromMillisecondsSinceEpoch(v * 1000);
        }

        if (value is String) {
          // Try ISO8601 parse first
          try {
            return DateTime.parse(value);
          } catch (_) {
            // Try numeric string
            final parsed = int.tryParse(value);
            if (parsed != null) {
              if (parsed > 1000000000000) return DateTime.fromMillisecondsSinceEpoch(parsed);
              return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
            }
          }
        }
      } catch (_) {}
      return DateTime.now();
    }

    return HazardModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity']?.toString() ?? 'medium',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      detectedAt: parseDetectedAt(json['detected_at']),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      verificationCount: json['verification_count'] as int? ?? 1,
      isVerified: json['is_verified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      lane: json['lane'] as String?,
      depth: json['depth'] != null ? (json['depth'] as num).toDouble() : null,
      reportedBy: json['reported_by'] as String?,
      reportedByName: json['reported_by_name'] as String?,
    );
  }
  
  /// Create copy with modified fields
  HazardModel copyWith({
    String? id,
    String? type,
    double? latitude,
    double? longitude,
    String? severity,
    double? confidence,
    DateTime? detectedAt,
    String? imageUrl,
    String? description,
    int? verificationCount,
    bool? isVerified,
    Map<String, dynamic>? metadata,
    String? lane,
    double? depth,
    String? reportedBy,
    String? reportedByName,
  }) {
    return HazardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      detectedAt: detectedAt ?? this.detectedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      verificationCount: verificationCount ?? this.verificationCount,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? this.metadata,
      lane: lane ?? this.lane,
      depth: depth ?? this.depth,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByName: reportedByName ?? this.reportedByName,
    );
  }
  
  /// Get user-friendly hazard type name
  String get typeName {
    switch (type) {
      case 'pothole':
        return 'Pothole';
      case 'speed_breaker':
        return 'Speed Breaker';
      case 'speed_breaker_unmarked':
        return 'Unmarked Speed Breaker';
      case 'obstacle':
        return 'Obstacle on Road';
      case 'closed_road':
        return 'Road Closed';
      case 'lane_blocked':
        return 'Lane Blocked';
      default:
        return 'Unknown Hazard';
    }
  }
  
  /// Get severity display text
  String get severityText {
    switch (severity) {
      case 'low':
        return 'Low Risk';
      case 'medium':
        return 'Medium Risk';
      case 'high':
        return 'High Risk';
      case 'critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }
}
