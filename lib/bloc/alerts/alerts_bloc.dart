import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:event_safety_app/models/alert_model.dart';
import 'package:event_safety_app/data/services/alert_api_service.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

/// BLoC for managing alerts and notifications
class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final Uuid _uuid = const Uuid();
  final AlertApiService _alertService = AlertApiService();
  List<AlertModel> _allAlerts = [];
  
  AlertsBloc() : super(AlertsInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<AddAlert>(_onAddAlert);
    on<MarkAlertAsRead>(_onMarkAlertAsRead);
    on<MarkAllAlertsAsRead>(_onMarkAllAlertsAsRead);
    on<DeleteAlert>(_onDeleteAlert);
    on<ClearAllAlerts>(_onClearAllAlerts);
    on<FilterAlertsByType>(_onFilterAlertsByType);
    on<FilterAlertsBySeverity>(_onFilterAlertsBySeverity);
  }
  
  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<AlertsState> emit,
  ) async {
    try {
      emit(AlertsLoading());
      
      // Load alerts from API
      _allAlerts = await _alertService.getUserAlerts();
      
      final unreadCount = _allAlerts.where((alert) => !alert.isRead).length;
      
      emit(AlertsLoaded(
        alerts: _allAlerts,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }
  
  void _onAddAlert(
    AddAlert event,
    Emitter<AlertsState> emit,
  ) {
    final alert = AlertModel(
      id: _uuid.v4(),
      title: event.title,
      message: event.message,
      type: event.type,
      severity: event.severity,
      timestamp: DateTime.now(),
      hazardId: event.hazardId,
      metadata: event.metadata,
    );
    
    // Insert at beginning (newest first)
    _allAlerts.insert(0, alert);
    
    // Emit new alert received
    emit(NewAlertReceived(alert));
    
    // Return to loaded state
    final unreadCount = _allAlerts.where((a) => !a.isRead).length;
    emit(AlertsLoaded(
      alerts: _allAlerts,
      unreadCount: unreadCount,
    ));
  }
  
  Future<void> _onMarkAlertAsRead(
    MarkAlertAsRead event,
    Emitter<AlertsState> emit,
  ) async {
    try {
      // Mark as read in API
      await _alertService.markAlertAsRead(event.alertId);
      
      final index = _allAlerts.indexWhere((alert) => alert.id == event.alertId);
      
      if (index != -1) {
        _allAlerts[index] = _allAlerts[index].copyWith(isRead: true);
        
        final unreadCount = _allAlerts.where((a) => !a.isRead).length;
        emit(AlertsLoaded(
          alerts: _allAlerts,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }
  
  void _onMarkAllAlertsAsRead(
    MarkAllAlertsAsRead event,
    Emitter<AlertsState> emit,
  ) {
    _allAlerts = _allAlerts
        .map((alert) => alert.copyWith(isRead: true))
        .toList();
    
    emit(AlertsLoaded(
      alerts: _allAlerts,
      unreadCount: 0,
    ));
  }
  
  void _onDeleteAlert(
    DeleteAlert event,
    Emitter<AlertsState> emit,
  ) {
    _allAlerts.removeWhere((alert) => alert.id == event.alertId);
    
    final unreadCount = _allAlerts.where((a) => !a.isRead).length;
    emit(AlertsLoaded(
      alerts: _allAlerts,
      unreadCount: unreadCount,
    ));
  }
  
  void _onClearAllAlerts(
    ClearAllAlerts event,
    Emitter<AlertsState> emit,
  ) {
    _allAlerts.clear();
    
    emit(const AlertsLoaded(
      alerts: [],
      unreadCount: 0,
    ));
  }
  
  void _onFilterAlertsByType(
    FilterAlertsByType event,
    Emitter<AlertsState> emit,
  ) {
    final filteredAlerts = _allAlerts
        .where((alert) => event.types.contains(alert.type))
        .toList();
    
    final unreadCount = filteredAlerts.where((a) => !a.isRead).length;
    emit(AlertsLoaded(
      alerts: filteredAlerts,
      unreadCount: unreadCount,
    ));
  }
  
  void _onFilterAlertsBySeverity(
    FilterAlertsBySeverity event,
    Emitter<AlertsState> emit,
  ) {
    final filteredAlerts = _allAlerts
        .where((alert) => event.severities.contains(alert.severity))
        .toList();
    
    final unreadCount = filteredAlerts.where((a) => !a.isRead).length;
    emit(AlertsLoaded(
      alerts: filteredAlerts,
      unreadCount: unreadCount,
    ));
  }
  
  /// Generate mock alerts for MVP testing
  List<AlertModel> _generateMockAlerts() {
    return [
      AlertModel(
        id: _uuid.v4(),
        title: 'Pothole Ahead',
        message: 'Major pothole detected 200m ahead on your route',
        type: 'hazard_proximity',
        severity: 'warning',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      AlertModel(
        id: _uuid.v4(),
        title: 'Maintenance Recommended',
        message: 'Your vehicle damage score is 850. Consider scheduling a maintenance check.',
        type: 'maintenance_due',
        severity: 'info',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AlertModel(
        id: _uuid.v4(),
        title: 'Unmarked Speed Breaker',
        message: 'Unmarked speed breaker detected ahead. Slow down.',
        type: 'hazard_proximity',
        severity: 'critical',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      AlertModel(
        id: _uuid.v4(),
        title: 'Road Closed',
        message: 'Road closure detected on NH-8. Consider alternate route.',
        type: 'hazard_proximity',
        severity: 'critical',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }
}
