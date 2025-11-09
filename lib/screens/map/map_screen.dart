import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:event_safety_app/core/theme/app_colors.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/core/utils/map_marker_generator.dart';
import 'package:event_safety_app/bloc/hazard/hazard_bloc.dart';
import 'package:event_safety_app/bloc/hazard/hazard_event.dart';
import 'package:event_safety_app/bloc/hazard/hazard_state.dart';
import 'package:event_safety_app/bloc/location/location_bloc.dart';
import 'package:event_safety_app/bloc/location/location_event.dart';
import 'package:event_safety_app/bloc/location/location_state.dart';
import 'package:event_safety_app/bloc/auth/auth_bloc.dart';
import 'package:event_safety_app/bloc/auth/auth_state.dart';
import 'package:event_safety_app/data/services/alert_notification_service.dart';
import 'package:event_safety_app/data/services/elevenlabs_tts_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' show cos, sqrt, asin;

/// Map screen showing hazards and user location using Google Maps
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  String? _currentUserId;
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  bool _locationTrackingStarted = false;
  List<String> _lastHazardIds = []; // Track which hazards we've already rendered
  
  // TTS for voice alerts
  ElevenLabsTTSService? _ttsService;
  final Set<String> _announcedHazards = {}; // Track which hazards have been announced
  Timer? _hazardCheckTimer;
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    // Load hazards and start location tracking
    context.read<HazardBloc>().add(const LoadHazards());
    if (!_locationTrackingStarted) {
      context.read<LocationBloc>().add(StartLocationTracking());
      _locationTrackingStarted = true;
    }
    
    // Get current user ID
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
    
    // Initialize TTS service if API key is available
    final apiKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      _ttsService = ElevenLabsTTSService(apiKey: apiKey);
      debugPrint('✅ [MAP] TTS service initialized');
    } else {
      debugPrint('⚠️ [MAP] ElevenLabs API key not found - TTS disabled');
    }
    
    // Start periodic hazard checking (every 5 seconds while navigating)
    _hazardCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkNearbyHazards();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _ttsService?.dispose();
    _hazardCheckTimer?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Set dark mode style if needed
    if (Theme.of(context).brightness == Brightness.dark) {
      _setDarkMapStyle();
    }
  }

  Future<void> _setDarkMapStyle() async {
    if (_mapController == null) return;
    const String darkMapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [{"color": "#242f3e"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#746855"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#242f3e"}]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#d59563"}]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#d59563"}]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [{"color": "#263c3f"}]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#6b9a76"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "#38414e"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry.stroke",
        "stylers": [{"color": "#212a37"}]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#9ca5b3"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [{"color": "#746855"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [{"color": "#1f2835"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#f3d19c"}]
      },
      {
        "featureType": "transit",
        "elementType": "geometry",
        "stylers": [{"color": "#2f3948"}]
      },
      {
        "featureType": "transit.station",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#d59563"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#17263c"}]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#515c6d"}]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#17263c"}]
      }
    ]
    ''';
    await _mapController!.setMapStyle(darkMapStyle);
  }

  /// Update markers on the map with custom circular icons
  Future<void> _updateMarkers(List<dynamic> hazards) async {
    // Check if hazards have actually changed
    final currentHazardIds = hazards.map((h) => h.id as String).toList()..sort();
    final lastIds = List<String>.from(_lastHazardIds)..sort();
    
    if (listEquals(currentHazardIds, lastIds)) {
      // Hazards haven't changed, skip update
      return;
    }
    
    if (kDebugMode) debugPrint('🗺️ [MAP] Updating ${hazards.length} markers on map');
    
    // Update tracking
    _lastHazardIds = currentHazardIds;
    
    // Keep user location marker
    final userLocationMarker = _markers.firstWhere(
      (m) => m.markerId.value == 'user_location',
      orElse: () => const Marker(markerId: MarkerId('none')),
    );
    
    // Create a new set to hold all markers
    final Set<Marker> newMarkers = {};
    
    // Re-add user location marker if it exists
    if (userLocationMarker.markerId.value != 'none' && _currentLocation != null) {
      newMarkers.add(userLocationMarker);
    }

    // Add hazard markers with custom circular icons
    for (var hazard in hazards) {
      final isCurrentUser = hazard.reportedBy == _currentUserId;
      
      // User's reports = Orange, Others' reports = Blue
      final markerColor = isCurrentUser 
          ? AppColors.accentOrange  // User's own hazards
          : AppColors.primaryBlue;  // Other users' hazards

      // Get appropriate icon for hazard type
      final hazardIcon = MapMarkerGenerator.getHazardIcon(hazard.type);

      // Generate custom circular marker
      final markerIcon = await MapMarkerGenerator.generateCircularMarker(
        icon: hazardIcon,
        color: markerColor,
        size: 100,
        iconColor: Colors.white,
        isVerified: hazard.isVerified,
      );

      newMarkers.add(
        Marker(
          markerId: MarkerId(hazard.id),
          position: LatLng(hazard.latitude, hazard.longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: hazard.typeName,
            snippet: hazard.isVerified 
                ? '✓ Verified by ${hazard.verificationCount} user${hazard.verificationCount > 1 ? "s" : ""}'
                : 'Reported by ${hazard.reportedByName ?? "Anonymous"}',
          ),
          onTap: () => _showHazardDetails(hazard),
        ),
      );
    }
    
    // Update markers atomically - replace all at once
    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
      });
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Check for nearby hazards and announce via TTS
  void _checkNearbyHazards() {
    if (_currentLocation == null || _ttsService == null) return;
    
    final hazardState = context.read<HazardBloc>().state;
    if (hazardState is! HazardLoaded) return;
    
    final hazards = hazardState.hazards;
    
    for (var hazard in hazards) {
      // Skip if already announced
      if (_announcedHazards.contains(hazard.id)) continue;
      
      // Calculate distance
      final distance = _calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        hazard.latitude,
        hazard.longitude,
      );
      
      // Announce if within 500 meters (0.5 km)
      if (distance <= 0.5) {
        _announceHazard(hazard, distance);
        _announcedHazards.add(hazard.id);
        
        // Remove from announced set after 5 minutes
        Future.delayed(const Duration(minutes: 5), () {
          _announcedHazards.remove(hazard.id);
        });
      }
    }
  }

  /// Announce hazard via TTS
  Future<void> _announceHazard(dynamic hazard, double distance) async {
    if (_ttsService == null) return;
    
    // Get hazard type message
    final Map<String, Map<String, String>> messages = {
      'en': {
        'pothole': 'Caution! Pothole ahead',
        'speed_breaker': 'Speed breaker ahead, slow down',
        'speed_breaker_unmarked': 'Warning! Unmarked speed breaker ahead',
        'obstacle': 'Obstacle detected on road',
        'closed_road': 'Road closed ahead, find alternate route',
        'lane_blocked': 'Lane blocked ahead',
        'water_logging': 'Water logging ahead, drive carefully',
        'animal_crossing': 'Animal crossing area, be alert',
        'debris': 'Debris on road ahead',
        'construction': 'Construction work ahead',
      },
      'hi': {
        'pothole': 'सावधान! आगे गड्ढा है',
        'speed_breaker': 'स्पीड ब्रेकर आगे है, धीमे चलें',
        'speed_breaker_unmarked': 'चेतावनी! आगे बिना निशान वाला स्पीड ब्रेकर',
        'obstacle': 'सड़क पर रुकावट',
        'closed_road': 'सड़क बंद है, वैकल्पिक मार्ग खोजें',
        'lane_blocked': 'लेन बंद है',
        'water_logging': 'आगे जल जमाव, सावधानी से चलें',
        'animal_crossing': 'जानवर क्रॉसिंग क्षेत्र, सतर्क रहें',
        'debris': 'आगे सड़क पर मलबा',
        'construction': 'आगे निर्माण कार्य',
      },
    };
    
    final languageMessages = messages[_selectedLanguage] ?? messages['en']!;
    String message = languageMessages[hazard.type] ?? 'Hazard ahead';
    
    // Add distance information
    final distanceMeters = (distance * 1000).round();
    if (_selectedLanguage == 'hi') {
      message = '$message, $distanceMeters मीटर आगे';
    } else {
      message = '$message, $distanceMeters meters ahead';
    }
    
    // Add severity warning for critical hazards
    if (hazard.severity == 'high' || hazard.severity == 'critical') {
      if (_selectedLanguage == 'hi') {
        message = 'अत्यावश्यक! $message';
      } else {
        message = 'URGENT! $message';
      }
    }
    
    debugPrint('🔊 [MAP] Announcing: $message');
    
    // Speak the message
    await _ttsService!.speak(message, languageCode: _selectedLanguage);
    
    // Show visual alert too
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _getHazardIcon(hazard.type),
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: hazard.severity == 'high' || hazard.severity == 'critical'
              ? AppColors.error
              : AppColors.warning,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Get icon for hazard type
  IconData _getHazardIcon(String type) {
    switch (type) {
      case 'pothole':
        return Icons.report_problem;
      case 'speed_breaker':
      case 'speed_breaker_unmarked':
        return Icons.speed;
      case 'obstacle':
        return Icons.block;
      case 'closed_road':
        return Icons.do_not_disturb;
      case 'lane_blocked':
        return Icons.warning;
      case 'water_logging':
        return Icons.water_drop;
      case 'animal_crossing':
        return Icons.pets;
      case 'debris':
        return Icons.cleaning_services;
      case 'construction':
        return Icons.construction;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazard Map'),
        actions: [
          // TTS Language Selector
          if (_ttsService != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              tooltip: 'Voice Language',
              onSelected: (String language) {
                setState(() {
                  _selectedLanguage = language;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Voice language: ${language == 'en' ? 'English' : 'हिंदी'}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'en',
                  child: Text('🇬🇧 English'),
                ),
                const PopupMenuItem<String>(
                  value: 'hi',
                  child: Text('🇮🇳 हिंदी (Hindi)'),
                ),
              ],
            ),
          IconButton(
            icon: Icon(_currentMapType == MapType.normal 
                ? Icons.satellite 
                : Icons.map),
            onPressed: () {
              setState(() {
                _currentMapType = _currentMapType == MapType.normal 
                    ? MapType.satellite 
                    : MapType.normal;
              });
            },
            tooltip: 'Toggle Map Type',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentLocation!, 15),
                );
              } else {
                // Try requesting permission and starting location tracking
                context.read<LocationBloc>().add(RequestLocationPermission());
              }
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (kDebugMode) debugPrint('🗺️ [MAP] Location state changed: ${state.runtimeType}');
              if (state is LocationLoaded) {
                if (kDebugMode) debugPrint('🗺️ [MAP] Location loaded: ${state.location.latitude}, ${state.location.longitude}');
                setState(() {
                  _currentLocation = LatLng(
                    state.location.latitude,
                    state.location.longitude,
                  );
                });
                // Center map on user location when first loaded
                if (_currentLocation != null && _mapController != null) {
                  if (kDebugMode) debugPrint('🗺️ [MAP] Centering map on user location');
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentLocation!, 15),
                  );
                }
              } else if (state is LocationPermissionDenied) {
                if (kDebugMode) debugPrint('❌ [MAP] Location permission denied');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location permission is required to show your position'),
                    action: SnackBarAction(label: 'Settings', onPressed: Geolocator.openLocationSettings),
                  ),
                );
              } else if (state is LocationServiceDisabled) {
                if (kDebugMode) debugPrint('❌ [MAP] Location service disabled');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enable location services'),
                    action: SnackBarAction(label: 'Settings', onPressed: Geolocator.openLocationSettings),
                  ),
                );
              } else if (state is LocationError) {
                if (kDebugMode) debugPrint('❌ [MAP] Location error: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location error: ${state.message}')),
                );
              }
            },
          ),
          // Listen for hazard submissions and refresh map
          BlocListener<HazardBloc, HazardState>(
            listener: (context, state) {
              if (kDebugMode) debugPrint('🗺️ [MAP] Hazard state changed: ${state.runtimeType}');
              if (state is HazardSubmitted) {
                if (kDebugMode) debugPrint('🗺️ [MAP] ✅ Hazard submitted: ${state.hazard.type}, refreshing map...');
                // Refresh hazards to show newly submitted one
                context.read<HazardBloc>().add(const LoadHazards());
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.hazard.typeName} reported successfully!'),
                    backgroundColor: AppColors.secondaryGreen,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is HazardLoaded) {
                if (kDebugMode) debugPrint('🗺️ [MAP] ✅ Hazards loaded: ${state.hazards.length} total');
              } else if (state is HazardSubmitting) {
                if (kDebugMode) debugPrint('🗺️ [MAP] ⏳ Submitting hazard...');
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // Google Maps with markers
            BlocBuilder<HazardBloc, HazardState>(
              builder: (context, hazardState) {
                // Update markers when hazards change (deferred to post-frame)
                if (hazardState is HazardLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _updateMarkers(hazardState.hazards);
                    }
                  });
                }
                
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(28.6139, 77.2090), // Default to Delhi
                    zoom: 15.0,
                  ),
                  mapType: _currentMapType,
                  markers: _markers,
                  // Only enable myLocation layer after we have a current location (and thus permissions)
                  myLocationEnabled: _currentLocation != null,
                  myLocationButtonEnabled: false, // We have our own button
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(5.0, 20.0),
                  onLongPress: (LatLng position) {
                    // TODO: Add new hazard at long-press location
                    _showAddHazardDialog(position);
                  },
                );
              },
            ),

            // Legend overlay (top right)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.accentOrange,  // User's reports = Orange
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Reports',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.grey900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,  // Others' reports = Blue
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Others\' Reports',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.grey900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hazard list overlay at bottom (keeping existing implementation)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Hazards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.grey900,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<HazardBloc>().add(RefreshHazards());
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Hazard list
                  Expanded(
                    child: BlocBuilder<HazardBloc, HazardState>(
                      builder: (context, state) {
                        if (state is HazardLoading) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading nearby hazards...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'First request may take 30-60s\n(server waking up)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is HazardLoaded) {
                          if (state.hazards.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 48,
                                      color: AppColors.secondaryGreen,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hazards found nearby',
                                      style: TextStyle(
                                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Great! Your area is clear.\nUse Camera tab to detect and report hazards.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isDark ? AppColors.grey400 : AppColors.grey500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.hazards.length,
                            itemBuilder: (context, index) {
                              final hazard = state.hazards[index];
                              return _HazardListItem(
                                hazard: hazard,
                                onTap: () {
                                  // Center map on hazard location for context
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(hazard.latitude, hazard.longitude),
                                      16,
                                    ),
                                  );
                                  _showHazardDetails(hazard);
                                },
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    ); // end of Scaffold
  }

  // Show dialog to add a new hazard at the given location
  void _showAddHazardDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Hazard'),
        content: Text(
          'Report a hazard at this location?\n\nLat: ${position.latitude.toStringAsFixed(5)}\nLng: ${position.longitude.toStringAsFixed(5)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to hazard reporting screen with pre-filled location
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature coming soon: Report hazard at this location'),
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  // Show hazard details in bottom sheet
  void _showHazardDetails(dynamic hazard) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Hazard type with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(hazard.severity).withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getHazardIcon(hazard.type),
                              color: _getSeverityColor(hazard.severity),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hazard.typeName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.white : AppColors.grey900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(hazard.severity),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    hazard.severityText.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Detection image (if available)
                      if (hazard.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            hazard.imageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: _getSeverityColor(hazard.severity).withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: isDark ? AppColors.grey600 : AppColors.grey400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image unavailable',
                                    style: TextStyle(
                                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(hazard.severity).withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Hazard details grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              Icons.access_time,
                              'Detected',
                              _getTimeAgo(hazard.detectedAt),
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.location_on,
                              'Coordinates',
                              '${hazard.latitude.toStringAsFixed(5)}, ${hazard.longitude.toStringAsFixed(5)}',
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.security,
                              'Risk Level',
                              hazard.severityText,
                              isDark,
                              color: _getSeverityColor(hazard.severity),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.person,
                              'Reported By',
                              hazard.reportedByName ?? 'Anonymous',
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.people,
                              'Total Reports',
                              '${hazard.verificationCount} ${hazard.verificationCount == 1 ? "person" : "people"}',
                              isDark,
                            ),
                            if (hazard.isVerified) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.verified,
                                'Status',
                                'Verified ✓',
                                isDark,
                                color: AppColors.secondaryGreen,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Navigate button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Integrate with navigation app
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.navigation),
                          label: const Text('Navigate Here'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color ?? (isDark ? AppColors.grey400 : AppColors.grey600),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? (isDark ? AppColors.white : AppColors.grey900),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return AppColors.severityLow;
      case 'medium':
        return AppColors.severityMedium;
      case 'high':
        return AppColors.severityHigh;
      case 'critical':
        return AppColors.severityCritical;
      default:
        return AppColors.grey500;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Hazard list item widget
class _HazardListItem extends StatelessWidget {
  final dynamic hazard;
  final VoidCallback? onTap;

  const _HazardListItem({required this.hazard, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getSeverityColor().withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getSeverityColor().withValues(alpha:0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getSeverityColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getHazardIcon(),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hazard.typeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(hazard.detectedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (hazard.isVerified) ...[
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.secondaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getSeverityColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hazard.severityText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor() {
    switch (hazard.severity) {
      case 'low':
        return AppColors.severityLow;
      case 'medium':
        return AppColors.severityMedium;
      case 'high':
        return AppColors.severityHigh;
      case 'critical':
        return AppColors.severityCritical;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getHazardIcon() {
    switch (hazard.type) {
      case 'pothole':
        return Icons.crisis_alert;
      case 'speed_breaker':
      case 'speed_breaker_unmarked':
        return Icons.speed;
      case 'obstacle':
        return Icons.block;
      case 'closed_road':
        return Icons.do_not_disturb_on;
      default:
        return Icons.warning;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
