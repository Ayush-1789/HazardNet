import 'package:equatable/equatable.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';

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
      'detectedAt': detectedAt.toIso8601String(),
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'description': description,
      'verification_count': verificationCount,
      'verificationCount': verificationCount,
      'is_verified': isVerified,
      'isVerified': isVerified,
      'metadata': metadata,
      'lane': lane,
      'depth': depth,
      'reported_by': reportedBy,
      'reportedBy': reportedBy,
      'reported_by_name': reportedByName,
      'reportedByName': reportedByName,
    };
  }

  static String? _resolveImageUrl(dynamic value) {
    if (value == null) return null;
    final String url = value.toString();
    if (url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    try {
      final apiUri = Uri.parse(AppConstants.baseApiUrl);
      final resolved = Uri(
        scheme: apiUri.scheme,
        host: apiUri.host,
        port: apiUri.hasPort ? apiUri.port : null,
        path: url.startsWith('/') ? url : '/$url',
      );
      return resolved.toString();
    } catch (_) {
      return url;
    }
  }

  static String? resolveImageUrl(String? url) => _resolveImageUrl(url);
  
  /// Create model from JSON
  factory HazardModel.fromJson(Map<String, dynamic> json) {
    dynamic read(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key];
        }
      }
      return null;
    }

    double? asDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    DateTime parseDetectedAt(dynamic value) {
      DateTime asLocal(DateTime dt) => dt.isUtc ? dt.toLocal() : dt;

      try {
        if (value == null) return DateTime.now();

        if (value is int) {
          final isMillisecondPrecision = value > 1000000000000;
          final epochMillis = isMillisecondPrecision ? value : value * 1000;
          return asLocal(DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true));
        }

        if (value is double) {
          final raw = value.toInt();
          final isMillisecondPrecision = raw > 1000000000000;
          final epochMillis = isMillisecondPrecision ? raw : raw * 1000;
          return asLocal(DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true));
        }

        if (value is String && value.isNotEmpty) {
          try {
            return asLocal(DateTime.parse(value));
          } catch (_) {
            final parsed = int.tryParse(value);
            if (parsed != null) {
              final isMillisecondPrecision = parsed > 1000000000000;
              final epochMillis = isMillisecondPrecision ? parsed : parsed * 1000;
              return asLocal(DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true));
            }
          }
        }
      } catch (_) {}

      return DateTime.now();
    }

    final metadataRaw = json['metadata'];
    Map<String, dynamic>? metadata;
    if (metadataRaw is Map<String, dynamic>) {
      metadata = metadataRaw;
    } else if (metadataRaw is String && metadataRaw.isNotEmpty) {
      metadata = {'raw': metadataRaw};
    }

    final verificationRaw = read(['verification_count', 'verificationCount', 'reports_count']);
    final isVerifiedRaw = read(['is_verified', 'isVerified']);

    return HazardModel(
      id: (read(['id']) ?? '').toString(),
      type: (read(['type']) ?? 'unknown').toString(),
      latitude: asDouble(read(['latitude'])) ?? 0.0,
      longitude: asDouble(read(['longitude'])) ?? 0.0,
      severity: (read(['severity', 'severity_level']) ?? 'medium').toString(),
      confidence: asDouble(read(['confidence'])) ?? 0.0,
      detectedAt: parseDetectedAt(read(['detected_at', 'detectedAt', 'created_at', 'createdAt', 'timestamp'])),
      imageUrl: _resolveImageUrl(read(['image_url', 'imageUrl', 'photo_url', 'photoUrl'])),
      description: read(['description']) as String?,
      verificationCount: asInt(verificationRaw) ?? 1,
      isVerified: isVerifiedRaw is bool
          ? isVerifiedRaw
          : (isVerifiedRaw != null && isVerifiedRaw.toString().toLowerCase() == 'true'),
      metadata: metadata,
      lane: read(['lane']) as String?,
      depth: asDouble(read(['depth'])),
      reportedBy: read(['reported_by', 'reportedBy'])?.toString(),
      reportedByName: read(['reported_by_name', 'reportedByName', 'reporter_name', 'reporterName'])?.toString(),
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
