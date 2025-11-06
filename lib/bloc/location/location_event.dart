import 'package:equatable/equatable.dart';

/// Events for Location BLoC
abstract class LocationEvent extends Equatable {
  const LocationEvent();
  
  @override
  List<Object?> get props => [];
}

class StartLocationTracking extends LocationEvent {}

class StopLocationTracking extends LocationEvent {}

class GetCurrentLocation extends LocationEvent {}

class UpdateLocation extends LocationEvent {
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  
  const UpdateLocation({
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
  });
  
  @override
  List<Object?> get props => [latitude, longitude, speed, heading];
}

class RequestLocationPermission extends LocationEvent {}
