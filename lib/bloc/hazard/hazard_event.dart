import 'package:equatable/equatable.dart';
import 'package:event_safety_app/models/hazard_model.dart';
import 'package:event_safety_app/models/location_model.dart';

/// Events for Hazard BLoC
abstract class HazardEvent extends Equatable {
  const HazardEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadHazards extends HazardEvent {
  final LocationModel? userLocation;
  final double? radiusKm;
  
  const LoadHazards({this.userLocation, this.radiusKm});
  
  @override
  List<Object?> get props => [userLocation, radiusKm];
}

class DetectHazard extends HazardEvent {
  final String type;
  final double confidence;
  final LocationModel location;
  final String? imagePath;
  final Map<String, dynamic>? sensorData;
  
  const DetectHazard({
    required this.type,
    required this.confidence,
    required this.location,
    this.imagePath,
    this.sensorData,
  });
  
  @override
  List<Object?> get props => [type, confidence, location, imagePath, sensorData];
}

class SubmitHazard extends HazardEvent {
  final HazardModel hazard;
  
  const SubmitHazard(this.hazard);
  
  @override
  List<Object> get props => [hazard];
}

class SubmitHazardWithImage extends HazardEvent {
  final HazardModel hazard;
  final String imagePath;
  
  const SubmitHazardWithImage({
    required this.hazard,
    required this.imagePath,
  });
  
  @override
  List<Object> get props => [hazard, imagePath];
}

class VerifyHazard extends HazardEvent {
  final String hazardId;
  final LocationModel userLocation;
  
  const VerifyHazard({
    required this.hazardId,
    required this.userLocation,
  });
  
  @override
  List<Object> get props => [hazardId, userLocation];
}

class CheckNearbyHazards extends HazardEvent {
  final LocationModel location;
  final double radiusMeters;
  
  const CheckNearbyHazards({
    required this.location,
    this.radiusMeters = 500.0,
  });
  
  @override
  List<Object> get props => [location, radiusMeters];
}

class FilterHazardsByType extends HazardEvent {
  final List<String> types;
  
  const FilterHazardsByType(this.types);
  
  @override
  List<Object> get props => [types];
}

class FilterHazardsBySeverity extends HazardEvent {
  final List<String> severities;
  
  const FilterHazardsBySeverity(this.severities);
  
  @override
  List<Object> get props => [severities];
}

class RefreshHazards extends HazardEvent {}

class DeleteHazard extends HazardEvent {
  final String hazardId;
  
  const DeleteHazard(this.hazardId);
  
  @override
  List<Object> get props => [hazardId];
}
