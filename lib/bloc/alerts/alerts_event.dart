import 'package:equatable/equatable.dart';

/// Events for Alerts BLoC
abstract class AlertsEvent extends Equatable {
  const AlertsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadAlerts extends AlertsEvent {}

class AddAlert extends AlertsEvent {
  final String title;
  final String message;
  final String type;
  final String severity;
  final String? hazardId;
  final Map<String, dynamic>? metadata;
  
  const AddAlert({
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    this.hazardId,
    this.metadata,
  });
  
  @override
  List<Object?> get props => [title, message, type, severity, hazardId, metadata];
}

class MarkAlertAsRead extends AlertsEvent {
  final String alertId;
  
  const MarkAlertAsRead(this.alertId);
  
  @override
  List<Object> get props => [alertId];
}

class MarkAllAlertsAsRead extends AlertsEvent {}

class DeleteAlert extends AlertsEvent {
  final String alertId;
  
  const DeleteAlert(this.alertId);
  
  @override
  List<Object> get props => [alertId];
}

class ClearAllAlerts extends AlertsEvent {}

class FilterAlertsByType extends AlertsEvent {
  final List<String> types;
  
  const FilterAlertsByType(this.types);
  
  @override
  List<Object> get props => [types];
}

class FilterAlertsBySeverity extends AlertsEvent {
  final List<String> severities;
  
  const FilterAlertsBySeverity(this.severities);
  
  @override
  List<Object> get props => [severities];
}
