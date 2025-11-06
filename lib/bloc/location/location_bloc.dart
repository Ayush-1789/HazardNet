import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:event_safety_app/models/location_model.dart';
import 'location_event.dart';
import 'location_state.dart';

/// BLoC for managing location tracking and updates
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionStreamSubscription;
  
  LocationBloc() : super(LocationInitial()) {
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<RequestLocationPermission>(_onRequestLocationPermission);
  }
  
  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(LocationLoading());
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationServiceDisabled());
        return;
      }
      
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationPermissionDenied());
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        emit(LocationPermissionDenied());
        return;
      }
      
      // Start listening to position stream
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );
      
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          final location = LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
            accuracy: position.accuracy,
            speed: position.speed,
            heading: position.heading,
            timestamp: position.timestamp ?? DateTime.now(),
          );
          
          emit(LocationLoaded(location: location, isTracking: true));
        },
        onError: (error) {
          emit(LocationError(error.toString()));
        },
      );
      
      // Get initial position
      Position position = await Geolocator.getCurrentPosition();
      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp ?? DateTime.now(),
      );
      
      emit(LocationLoaded(location: location, isTracking: true));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
  
  Future<void> _onStopLocationTracking(
    StopLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(LocationLoaded(
        location: currentState.location,
        isTracking: false,
      ));
    }
  }
  
  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(LocationLoading());
      
      Position position = await Geolocator.getCurrentPosition();
      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp ?? DateTime.now(),
      );
      
      emit(LocationLoaded(location: location));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
  
  void _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) {
    final location = LocationModel(
      latitude: event.latitude,
      longitude: event.longitude,
      speed: event.speed,
      heading: event.heading,
      timestamp: DateTime.now(),
    );
    
    final isTracking = state is LocationLoaded 
        ? (state as LocationLoaded).isTracking 
        : false;
    
    emit(LocationLoaded(location: location, isTracking: isTracking));
  }
  
  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        emit(LocationPermissionDenied());
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
