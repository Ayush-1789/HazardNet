import 'package:equatable/equatable.dart';
import 'package:event_safety_app/models/alert_model.dart';

/// States for Alerts BLoC
abstract class AlertsState extends Equatable {
  const AlertsState();
  
  @override
  List<Object?> get props => [];
}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final List<AlertModel> alerts;
  final int unreadCount;
  
  const AlertsLoaded({
    required this.alerts,
    this.unreadCount = 0,
  });
  
  @override
  List<Object> get props => [alerts, unreadCount];
}

class NewAlertReceived extends AlertsState {
  final AlertModel alert;
  
  const NewAlertReceived(this.alert);
  
  @override
  List<Object> get props => [alert];
}

class AlertsError extends AlertsState {
  final String message;
  
  const AlertsError(this.message);
  
  @override
  List<Object> get props => [message];
}
