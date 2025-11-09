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
      print('📍 [LOCATION] Starting location tracking...');
      emit(LocationLoading());

      // Check permissions first (so we trigger runtime permission dialog if needed)
      LocationPermission permission = await Geolocator.checkPermission();
      print('📍 [LOCATION] Current permission: $permission');
      if (permission == LocationPermission.denied) {
        print('📍 [LOCATION] Requesting permission...');
        permission = await Geolocator.requestPermission();
        print('📍 [LOCATION] Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          print('❌ [LOCATION] Permission denied');
          emit(LocationPermissionDenied());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ [LOCATION] Permission denied forever');
        emit(LocationPermissionDenied());
        return;
      }

      // Now check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📍 [LOCATION] Service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        print('❌ [LOCATION] Location service is disabled');
        emit(LocationServiceDisabled());
        return;
      }

      print('✅ [LOCATION] Permissions granted and service enabled, getting position...');
      
      // Get initial position first
      print('📍 [LOCATION] Getting initial position...');
      Position position = await Geolocator.getCurrentPosition();
      print('✅ [LOCATION] Initial position: ${position.latitude}, ${position.longitude}');
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
      
      // Start listening to position stream (dispatch UpdateLocation events instead of emitting directly)
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );
      
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          print('📍 [LOCATION] Stream update: ${position.latitude}, ${position.longitude}');
          // Use event dispatch instead of direct emit to avoid "emit after completion" error
          add(UpdateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            speed: position.speed,
            heading: position.heading,
          ));
        },
        onError: (error) {
          print('❌ [LOCATION] Stream error: $error');
          // Don't emit here - stream errors should not stop the bloc
        },
      );
    } catch (e) {
      print('❌ [LOCATION] Error: $e');
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
      print('📍 [LOCATION] Requesting runtime permission (via RequestLocationPermission event)');
      LocationPermission permission = await Geolocator.requestPermission();

      print('📍 [LOCATION] Permission result: $permission');

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(LocationPermissionDenied());
        return;
      }

      // If permission granted, attempt to start tracking
      add(StartLocationTracking());
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
