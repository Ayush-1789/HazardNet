import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:event_safety_app/models/hazard_model.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/data/services/hazard_api_service.dart';
import 'hazard_event.dart';
import 'hazard_state.dart';

/// BLoC for managing hazard detection and reporting
class HazardBloc extends Bloc<HazardEvent, HazardState> {
  final Uuid _uuid = const Uuid();
  final HazardApiService _hazardService = HazardApiService();
  List<HazardModel> _allHazards = [];
  
  HazardBloc() : super(HazardInitial()) {
    on<LoadHazards>(_onLoadHazards);
    on<DetectHazard>(_onDetectHazard);
    on<SubmitHazard>(_onSubmitHazard);
    on<VerifyHazard>(_onVerifyHazard);
    on<CheckNearbyHazards>(_onCheckNearbyHazards);
    on<FilterHazardsByType>(_onFilterHazardsByType);
    on<FilterHazardsBySeverity>(_onFilterHazardsBySeverity);
    on<RefreshHazards>(_onRefreshHazards);
    on<DeleteHazard>(_onDeleteHazard);
  }
  
  Future<void> _onLoadHazards(
    LoadHazards event,
    Emitter<HazardState> emit,
  ) async {
    try {
      emit(HazardLoading());
      
      // Fetch hazards from API
      if (event.userLocation != null) {
        // Get nearby hazards based on user location
        _allHazards = await _hazardService.getNearbyHazards(
          latitude: event.userLocation!.latitude,
          longitude: event.userLocation!.longitude,
          radiusKm: AppConstants.proximityRadiusMeters / 1000, // Convert to km
        );
      } else {
        // Get all hazards
        _allHazards = await _hazardService.getAllHazards();
      }
      
      // Filter nearby hazards if user location provided
      List<HazardModel> nearbyHazards = [];
      if (event.userLocation != null) {
        nearbyHazards = _allHazards.where((hazard) {
          final hazardLocation = event.userLocation!;
          final distance = hazardLocation.distanceTo(
            event.userLocation!.copyWith(
              latitude: hazard.latitude,
              longitude: hazard.longitude,
            ),
          );
          return distance <= AppConstants.proximityRadiusMeters;
        }).toList();
      }
      
      emit(HazardLoaded(
        hazards: _allHazards,
        nearbyHazards: nearbyHazards,
      ));
    } catch (e) {
      emit(HazardError(e.toString()));
    }
  }
  
  Future<void> _onDetectHazard(
    DetectHazard event,
    Emitter<HazardState> emit,
  ) async {
    try {
      // Only process if confidence is above threshold
      if (event.confidence < AppConstants.confidenceThreshold) {
        return;
      }
      
      // Determine severity based on type and confidence
      String severity = _determineSeverity(event.type, event.confidence);
      
      final hazard = HazardModel(
        id: _uuid.v4(),
        type: event.type,
        latitude: event.location.latitude,
        longitude: event.location.longitude,
        severity: severity,
        confidence: event.confidence,
        detectedAt: DateTime.now(),
        metadata: event.sensorData,
      );
      
      emit(HazardDetected(hazard: hazard));
    } catch (e) {
      emit(HazardError(e.toString()));
    }
  }
  
  Future<void> _onSubmitHazard(
    SubmitHazard event,
    Emitter<HazardState> emit,
  ) async {
    try {
      emit(HazardSubmitting());
      
      // Submit hazard to API
      final submittedHazard = await _hazardService.reportHazard(
        type: event.hazard.type,
        latitude: event.hazard.latitude,
        longitude: event.hazard.longitude,
        severity: event.hazard.severity,
        confidence: event.hazard.confidence,
        imageUrl: event.hazard.imageUrl,
        description: event.hazard.description,
      );
      
      // Add to local list
      _allHazards.add(submittedHazard);
      
      emit(HazardSubmitted(submittedHazard));
      
      // Return to loaded state
      emit(HazardLoaded(hazards: _allHazards));
    } catch (e) {
      emit(HazardError(e.toString()));
    }
  }
  
  Future<void> _onVerifyHazard(
    VerifyHazard event,
    Emitter<HazardState> emit,
  ) async {
    try {
      // Submit verification to API
      await _hazardService.verifyHazard(event.hazardId);
      
      // Find hazard and increment verification count
      final index = _allHazards.indexWhere((h) => h.id == event.hazardId);
      if (index != -1) {
        final hazard = _allHazards[index];
        final updatedHazard = hazard.copyWith(
          verificationCount: hazard.verificationCount + 1,
          isVerified: hazard.verificationCount + 1 >= AppConstants.minReportsForVerification,
        );
        
        _allHazards[index] = updatedHazard;
        
        emit(HazardLoaded(hazards: _allHazards));
      }
    } catch (e) {
      emit(HazardError(e.toString()));
    }
  }
  
  Future<void> _onCheckNearbyHazards(
    CheckNearbyHazards event,
    Emitter<HazardState> emit,
  ) async {
    try {
      final nearbyHazards = _allHazards.where((hazard) {
        final hazardLocation = event.location.copyWith(
          latitude: hazard.latitude,
          longitude: hazard.longitude,
        );
        final distance = event.location.distanceTo(hazardLocation);
        return distance <= event.radiusMeters;
      }).toList();
      
      if (nearbyHazards.isNotEmpty) {
        emit(HazardsNearby(
          hazards: nearbyHazards,
          proximityMeters: event.radiusMeters,
        ));
      }
    } catch (e) {
      emit(HazardError(e.toString()));
    }
  }
  
  void _onFilterHazardsByType(
    FilterHazardsByType event,
    Emitter<HazardState> emit,
  ) {
    final filteredHazards = _allHazards
        .where((hazard) => event.types.contains(hazard.type))
        .toList();
    
    emit(HazardLoaded(hazards: filteredHazards));
  }
  
  void _onFilterHazardsBySeverity(
    FilterHazardsBySeverity event,
    Emitter<HazardState> emit,
  ) {
    final filteredHazards = _allHazards
        .where((hazard) => event.severities.contains(hazard.severity))
        .toList();
    
    emit(HazardLoaded(hazards: filteredHazards));
  }
  
  Future<void> _onRefreshHazards(
    RefreshHazards event,
    Emitter<HazardState> emit,
  ) async {
    add(const LoadHazards());
  }
  
  Future<void> _onDeleteHazard(
    DeleteHazard event,
    Emitter<HazardState> emit,
  ) async {
    try {
      _allHazards.removeWhere((h) => h.id == event.hazardId);
      
      // TODO: Delete from API
      await Future.delayed(const Duration(milliseconds: 300));
      
      emit(HazardLoaded(hazards: _allHazards));
    } catch (e) {
      emit(HazardError(e.toString()));
    }
  }
  
  /// Determine severity based on hazard type and confidence
  String _determineSeverity(String type, double confidence) {
    if (type == AppConstants.hazardTypeClosedRoad) {
      return AppConstants.severityCritical;
    }
    
    if (type == AppConstants.hazardTypeSpeedBreakerUnmarked || 
        type == AppConstants.hazardTypeObstacle) {
      return confidence > 0.85 ? AppConstants.severityHigh : AppConstants.severityMedium;
    }
    
    if (type == AppConstants.hazardTypePothole) {
      if (confidence > 0.9) return AppConstants.severityHigh;
      if (confidence > 0.75) return AppConstants.severityMedium;
      return AppConstants.severityLow;
    }
    
    return AppConstants.severityMedium;
  }
  
  /// Generate mock hazards for MVP testing
  List<HazardModel> _generateMockHazards() {
    return [
      HazardModel(
        id: _uuid.v4(),
        type: AppConstants.hazardTypePothole,
        latitude: 28.6139,
        longitude: 77.2090,
        severity: AppConstants.severityHigh,
        confidence: 0.92,
        detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
        verificationCount: 5,
        isVerified: true,
        description: 'Large pothole on main road',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
        reportedBy: 'user123',
        reportedByName: 'Rajesh Kumar',
      ),
      HazardModel(
        id: _uuid.v4(),
        type: AppConstants.hazardTypeSpeedBreakerUnmarked,
        latitude: 28.6150,
        longitude: 77.2100,
        severity: AppConstants.severityMedium,
        confidence: 0.88,
        detectedAt: DateTime.now().subtract(const Duration(hours: 5)),
        verificationCount: 3,
        isVerified: true,
        imageUrl: 'https://images.unsplash.com/photo-1580883954942-b8abf952e027?w=800',
        reportedBy: 'user456',
        reportedByName: 'Priya Sharma',
      ),
      HazardModel(
        id: _uuid.v4(),
        type: AppConstants.hazardTypeObstacle,
        latitude: 28.6120,
        longitude: 77.2080,
        severity: AppConstants.severityHigh,
        confidence: 0.95,
        detectedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        verificationCount: 2,
        imageUrl: 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800',
        reportedBy: 'user789',
        reportedByName: 'Amit Singh',
      ),
    ];
  }
}
