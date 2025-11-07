/// Sensor Data API service
/// Handles sensor data upload for impact detection and analytics

import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/data/services/api_service.dart';

class SensorDataApiService {
  final ApiService _apiService;

  SensorDataApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Upload sensor data
  Future<void> uploadSensorData({
    required String tripId,
    required double latitude,
    required double longitude,
    required Map<String, double> accelerometer, // {x, y, z}
    required Map<String, double> gyroscope, // {x, y, z}
    required double speed,
    required double heading,
    required bool impactDetected,
    double? impactSeverity,
  }) async {
    await _apiService.post(
      AppConstants.sensorDataEndpoint,
      body: {
        'trip_id': tripId,
        'latitude': latitude,
        'longitude': longitude,
        'accelerometer': accelerometer,
        'gyroscope': gyroscope,
        'speed': speed,
        'heading': heading,
        'impact_detected': impactDetected,
        'impact_severity': impactSeverity,
      },
    );
  }

  /// Upload batch sensor data (for better performance)
  Future<void> uploadBatchSensorData({
    required List<Map<String, dynamic>> sensorDataBatch,
  }) async {
    await _apiService.post(
      '${AppConstants.sensorDataEndpoint}/batch',
      body: {
        'sensor_data': sensorDataBatch,
      },
    );
  }

  /// Get sensor data for a trip
  Future<List<Map<String, dynamic>>> getTripSensorData(String tripId) async {
    final response = await _apiService.get(
      AppConstants.sensorDataEndpoint,
      queryParams: {
        'trip_id': tripId,
      },
    );

    final sensorData = response['sensor_data'] as List<dynamic>;
    return sensorData.cast<Map<String, dynamic>>();
  }

  /// Get impact detections
  Future<List<Map<String, dynamic>>> getImpactDetections({
    String? tripId,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'impact_detected': 'true',
      'limit': limit.toString(),
    };

    if (tripId != null) {
      queryParams['trip_id'] = tripId;
    }

    final response = await _apiService.get(
      AppConstants.sensorDataEndpoint,
      queryParams: queryParams,
    );

    final impacts = response['sensor_data'] as List<dynamic>;
    return impacts.cast<Map<String, dynamic>>();
  }
}
