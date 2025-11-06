import 'package:equatable/equatable.dart';
import 'package:event_safety_app/models/location_model.dart';

/// States for Location BLoC
abstract class LocationState extends Equatable {
  const LocationState();
  
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final LocationModel location;
  final bool isTracking;
  
  const LocationLoaded({
    required this.location,
    this.isTracking = false,
  });
  
  @override
  List<Object?> get props => [location, isTracking];
}

class LocationError extends LocationState {
  final String message;
  
  const LocationError(this.message);
  
  @override
  List<Object> get props => [message];
}

class LocationPermissionDenied extends LocationState {}

class LocationServiceDisabled extends LocationState {}
