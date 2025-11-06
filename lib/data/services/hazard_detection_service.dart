/// Example API service for hazard detection
/// This is a template - replace with your actual API implementation

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/models/hazard_model.dart';
import 'package:event_safety_app/models/location_model.dart';

class HazardDetectionService {
  final http.Client _client;

  HazardDetectionService({http.Client? client}) 
      : _client = client ?? http.Client();

  /// Send image frame to ML model API for hazard detection
  Future<List<HazardModel>> detectHazards({
    required Uint8List imageBytes,
    required LocationModel location,
  }) async {
    try {
      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      // Prepare request body
      final requestBody = {
        'image': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'speed': location.speed,
          'heading': location.heading,
        },
      };

      // Send POST request to ML API
      final response = await _client.post(
        Uri.parse(
          '${AppConstants.baseApiUrl}${AppConstants.hazardDetectionEndpoint}',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse detections from API response
        final detections = data['detections'] as List<dynamic>;
        
        return detections.map((detection) {
          return HazardModel(
            id: _generateId(),
            type: detection['type'] as String,
            latitude: location.latitude,
            longitude: location.longitude,
            severity: detection['severity'] as String,
            confidence: (detection['confidence'] as num).toDouble(),
            detectedAt: DateTime.now(),
            metadata: {
              'bbox': detection['bbox'],
              'processing_time_ms': data['processing_time_ms'],
            },
          );
        }).toList();
      } else {
        throw Exception('Failed to detect hazards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hazard detection error: $e');
    }
  }

  /// Submit verified hazard to backend database
  Future<bool> submitHazard(HazardModel hazard) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseApiUrl}/hazards'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(hazard.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error submitting hazard: $e');
      return false;
    }
  }

  /// Fetch nearby hazards from database
  Future<List<HazardModel>> getNearbyHazards({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '${AppConstants.baseApiUrl}/hazards?lat=$latitude&lng=$longitude&radius=$radiusKm',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => HazardModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch hazards');
      }
    } catch (e) {
      print('Error fetching hazards: $e');
      return [];
    }
  }

  /// Verify an existing hazard
  Future<bool> verifyHazard(String hazardId) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseApiUrl}/hazards/$hazardId/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying hazard: $e');
      return false;
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void dispose() {
    _client.close();
  }
}

// USAGE EXAMPLE:
// 
// final service = HazardDetectionService();
// 
// // In camera bloc, when processing frame:
// final hazards = await service.detectHazards(
//   imageBytes: cameraImageBytes,
//   location: currentLocation,
// );
// 
// // Submit hazard to database:
// await service.submitHazard(hazard);
// 
// // Get nearby hazards:
// final nearby = await service.getNearbyHazards(
//   latitude: 28.6139,
//   longitude: 77.2090,
//   radiusKm: 5.0,
// );
