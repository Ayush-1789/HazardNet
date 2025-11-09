/// Hazard API service
/// Handles hazard reporting, retrieval, and verification

import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/data/services/api_service.dart';
import 'package:event_safety_app/models/hazard_model.dart';

class HazardApiService {
  final ApiService _apiService;

  HazardApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Upload hazard image and return the image URL
  Future<String> uploadHazardImage(String hazardId, String imagePath) async {
    final response = await _apiService.uploadFile(
      '/gamification/$hazardId/photos',
      filePath: imagePath,
      fieldName: 'photos',
    );

    // Extract the first photo URL from the response
    final photos = response['photos'] as List<dynamic>;
    if (photos.isEmpty) {
      throw Exception('No photo URL returned from server');
    }
    
    final photoUrl = photos[0]['photo_url'] as String;
    return photoUrl;
  }

  /// Report a new hazard
  Future<HazardModel> reportHazard({
    required String type,
    required double latitude,
    required double longitude,
    required String severity,
    required double confidence,
    String? description,
    String? imageUrl,
    double? depth,
    String? lane,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiService.post(
      AppConstants.reportHazardEndpoint,
      body: {
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'severity': severity,
        'confidence': confidence,
        'description': description,
        'image_url': imageUrl,
        'imageUrl': imageUrl,
        'depth': depth,
        'lane': lane,
        'metadata': metadata,
      },
    );

    final hazardData = response['hazard'] as Map<String, dynamic>;
    return HazardModel.fromJson(hazardData);
  }

  /// Get nearby hazards
  Future<List<HazardModel>> getNearbyHazards({
    required double latitude,
    required double longitude,
    double radiusKm = 0.5, // 500 meters default
  }) async {
    final response = await _apiService.get(
      AppConstants.nearbyHazardsEndpoint,
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radiusKm.toString(),
      },
    );

    final hazardsData = response['hazards'] as List<dynamic>;
    return hazardsData
        .map((json) => HazardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all hazards
  Future<List<HazardModel>> getAllHazards({
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _apiService.get(
      AppConstants.hazardsEndpoint,
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final hazardsData = response['hazards'] as List<dynamic>;
    return hazardsData
        .map((json) => HazardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get hazard by ID
  Future<HazardModel> getHazardById(String hazardId) async {
    final response = await _apiService.get('${AppConstants.hazardsEndpoint}/$hazardId');
    final dynamic payload = response['hazard'] ?? response;
    if (payload is Map<String, dynamic>) {
      return HazardModel.fromJson(payload);
    }
    throw Exception('Unexpected hazard response structure');
  }

  /// Verify an existing hazard
  Future<HazardModel> verifyHazard(String hazardId, {String? notes}) async {
    final endpoint = AppConstants.verifyHazardEndpoint.replaceAll(':id', hazardId);
    
    final response = await _apiService.post(
      endpoint,
      body: {
        'notes': notes,
      },
    );

    final hazardData = response['hazard'] as Map<String, dynamic>;
    return HazardModel.fromJson(hazardData);
  }

  /// Get hazards by type
  Future<List<HazardModel>> getHazardsByType(String type) async {
    final response = await _apiService.get(
      AppConstants.hazardsEndpoint,
      queryParams: {
        'type': type,
      },
    );

    final hazardsData = response['hazards'] as List<dynamic>;
    return hazardsData
        .map((json) => HazardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get critical unverified hazards
  Future<List<HazardModel>> getCriticalUnverifiedHazards() async {
    final response = await _apiService.get(
      AppConstants.hazardsEndpoint,
      queryParams: {
        'is_verified': 'false',
        'severity': 'critical,high',
      },
    );

    final hazardsData = response['hazards'] as List<dynamic>;
    return hazardsData
        .map((json) => HazardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Report hazard as resolved
  Future<void> markHazardResolved(String hazardId) async {
    await _apiService.patch(
      '${AppConstants.hazardsEndpoint}/$hazardId/resolve',
    );
  }
}
