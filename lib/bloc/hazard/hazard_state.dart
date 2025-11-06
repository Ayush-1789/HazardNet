import 'package:equatable/equatable.dart';
import 'package:event_safety_app/models/hazard_model.dart';

/// States for Hazard BLoC
abstract class HazardState extends Equatable {
  const HazardState();
  
  @override
  List<Object?> get props => [];
}

class HazardInitial extends HazardState {}

class HazardLoading extends HazardState {}

class HazardLoaded extends HazardState {
  final List<HazardModel> hazards;
  final List<HazardModel> nearbyHazards;
  
  const HazardLoaded({
    required this.hazards,
    this.nearbyHazards = const [],
  });
  
  @override
  List<Object> get props => [hazards, nearbyHazards];
}

class HazardDetected extends HazardState {
  final HazardModel hazard;
  final bool isNewDetection;
  
  const HazardDetected({
    required this.hazard,
    this.isNewDetection = true,
  });
  
  @override
  List<Object> get props => [hazard, isNewDetection];
}

class HazardSubmitting extends HazardState {}

class HazardSubmitted extends HazardState {
  final HazardModel hazard;
  
  const HazardSubmitted(this.hazard);
  
  @override
  List<Object> get props => [hazard];
}

class HazardError extends HazardState {
  final String message;
  
  const HazardError(this.message);
  
  @override
  List<Object> get props => [message];
}

class HazardsNearby extends HazardState {
  final List<HazardModel> hazards;
  final double proximityMeters;
  
  const HazardsNearby({
    required this.hazards,
    required this.proximityMeters,
  });
  
  @override
  List<Object> get props => [hazards, proximityMeters];
}
