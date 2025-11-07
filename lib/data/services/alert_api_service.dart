/// Alert API service
/// Handles user alerts and notifications

import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/data/services/api_service.dart';
import 'package:event_safety_app/models/alert_model.dart';

class AlertApiService {
  final ApiService _apiService;

  AlertApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get user alerts
  Future<List<AlertModel>> getUserAlerts({
    bool? isRead,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (isRead != null) {
      queryParams['is_read'] = isRead.toString();
    }

    final response = await _apiService.get(
      AppConstants.alertsEndpoint,
      queryParams: queryParams,
    );

    final alertsData = response['alerts'] as List<dynamic>;
    return alertsData
        .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get unread alerts count
  Future<int> getUnreadAlertsCount() async {
    final response = await _apiService.get(
      '${AppConstants.alertsEndpoint}/unread-count',
    );

    return response['count'] as int;
  }

  /// Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    final endpoint = AppConstants.markAlertReadEndpoint.replaceAll(':id', alertId);
    await _apiService.patch(endpoint);
  }

  /// Mark all alerts as read
  Future<void> markAllAlertsAsRead() async {
    await _apiService.patch('${AppConstants.alertsEndpoint}/mark-all-read');
  }

  /// Delete alert
  Future<void> deleteAlert(String alertId) async {
    await _apiService.delete('${AppConstants.alertsEndpoint}/$alertId');
  }

  /// Get proximity alerts for current location
  Future<List<AlertModel>> getProximityAlerts({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiService.get(
      '${AppConstants.alertsEndpoint}/proximity',
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );

    final alertsData = response['alerts'] as List<dynamic>;
    return alertsData
        .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
