/// Trip API service
/// Handles trip session tracking and analytics

import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/data/services/api_service.dart';

class TripApiService {
  final ApiService _apiService;

  TripApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Start a new trip session
  Future<Map<String, dynamic>> startTrip({
    required double startLatitude,
    required double startLongitude,
    String? startAddress,
  }) async {
    final response = await _apiService.post(
      AppConstants.startTripEndpoint,
      body: {
        'start_location': {
          'lat': startLatitude,
          'lng': startLongitude,
          'address': startAddress,
        },
      },
    );

    return response['trip'] as Map<String, dynamic>;
  }

  /// End current trip session
  Future<Map<String, dynamic>> endTrip({
    required String tripId,
    required double endLatitude,
    required double endLongitude,
    String? endAddress,
    required double distanceKm,
    required int durationMinutes,
    required int hazardsDetected,
    double? averageSpeed,
    double? maxSpeed,
    int? damageScoreIncrease,
  }) async {
    final response = await _apiService.patch(
      AppConstants.endTripEndpoint,
      body: {
        'trip_id': tripId,
        'end_location': {
          'lat': endLatitude,
          'lng': endLongitude,
          'address': endAddress,
        },
        'distance_km': distanceKm,
        'duration_minutes': durationMinutes,
        'hazards_detected': hazardsDetected,
        'average_speed': averageSpeed,
        'max_speed': maxSpeed,
        'damage_score_increase': damageScoreIncrease,
      },
    );

    return response['trip'] as Map<String, dynamic>;
  }

  /// Get trip history
  Future<List<Map<String, dynamic>>> getTripHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiService.get(
      AppConstants.tripHistoryEndpoint,
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final tripsData = response['trips'] as List<dynamic>;
    return tripsData.cast<Map<String, dynamic>>();
  }

  /// Get trip by ID
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    final response = await _apiService.get('/trips/$tripId');
    return response['trip'] as Map<String, dynamic>;
  }

  /// Get trip statistics
  Future<Map<String, dynamic>> getTripStats() async {
    final response = await _apiService.get('/trips/stats');
    return response['stats'] as Map<String, dynamic>;
  }
}
