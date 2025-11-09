import 'package:equatable/equatable.dart';

/// Model representing a user alert/notification
class AlertModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type; // hazard_proximity, maintenance_due, system, etc.
  final String severity; // info, warning, critical
  final DateTime timestamp;
  final bool isRead;
  final String? hazardId; // Related hazard if applicable
  final Map<String, dynamic>? metadata;
  final String? actionUrl; // Deep link for action
  
  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    this.hazardId,
    this.metadata,
    this.actionUrl,
  });
  
  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    severity,
    timestamp,
    isRead,
    hazardId,
    metadata,
    actionUrl,
  ];
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'hazard_id': hazardId,
      'metadata': metadata,
      'action_url': actionUrl,
    };
  }
  
  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      // Support both snake_case and camelCase for backend compatibility
      isRead: (json['is_read'] ?? json['isRead']) as bool? ?? false,
      hazardId: (json['hazard_id'] ?? json['hazardId']) as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      actionUrl: (json['action_url'] ?? json['actionUrl']) as String?,
    );
  }
  
  AlertModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? severity,
    DateTime? timestamp,
    bool? isRead,
    String? hazardId,
    Map<String, dynamic>? metadata,
    String? actionUrl,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      hazardId: hazardId ?? this.hazardId,
      metadata: metadata ?? this.metadata,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
