/// App-wide constants for HazardNet application
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // App Info
  static const String appName = 'HazardNet';
  static const String appVersion = '1.0.0';
  
  // API Configuration - Using Local Backend Connected to Neon Database
  // Railway: https://hazardnet-production.up.railway.app/api (Always online)
  // Fallback: Render.com (https://hazardnet-9yd2.onrender.com/api)
  // Local: http://192.168.31.39:3000/api (When laptop backend is running)
  static final String baseApiUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api'; // Default to emulator loopback
  
  // Authentication Endpoints (match backend routes)
  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authLogoutEndpoint = '/auth/logout';
  // Backend provides /auth/status and /auth/profile endpoints
  static const String authCheckEndpoint = '/auth/status';
  
  // Hazard Endpoints
  static const String hazardsEndpoint = '/hazards';
  static const String nearbyHazardsEndpoint = '/hazards/nearby';
  static const String verifyHazardEndpoint = '/hazards/:id/verify';
  static const String reportHazardEndpoint = '/hazards/report';
  
  // Alert Endpoints
  static const String alertsEndpoint = '/alerts';
  static const String markAlertReadEndpoint = '/alerts/:id/read';
  
  // User / profile endpoints (served under /auth in backend)
  static const String userProfileEndpoint = '/auth/profile';
  static const String updateDamageScoreEndpoint = '/auth/damage-score';
  static const String userStatsEndpoint = '/users/stats';
  
  // Trip Endpoints
  static const String startTripEndpoint = '/trips/start';
  static const String endTripEndpoint = '/trips/end';
  static const String tripHistoryEndpoint = '/trips/history';
  
  // Sensor Data Endpoint
  static const String sensorDataEndpoint = '/sensor-data';
  
  // ML Model Endpoint (separate service)
  static final String mlApiUrl =
      dotenv.env['ML_API_URL'] ?? 'http://10.0.2.2:5000';
  static const String hazardDetectionEndpoint = '/detect/hazard';
  
  // Hazard Detection Settings
  static const double confidenceThreshold = 0.65; // Minimum confidence for hazard detection
  static const int detectionFPS = 5; // Frames per second for hazard detection
  static const int maxFrameQueueSize = 10;
  
  // Location Settings
  static const double proximityRadiusMeters = 500.0; // Alert radius in meters
  static const int locationUpdateIntervalMs = 5000; // Location update frequency
  static const double hazardProximityThreshold = 100.0; // Distance to trigger alert
  
  // Map Settings
  static const double defaultZoom = 15.0;
  static const double defaultLatitude = 28.6139; // Delhi (default)
  static const double defaultLongitude = 77.2090;
  
  // Hazard Types
  static const String hazardTypePothole = 'pothole';
  static const String hazardTypeSpeedBreaker = 'speed_breaker';
  static const String hazardTypeSpeedBreakerUnmarked = 'speed_breaker_unmarked';
  static const String hazardTypeObstacle = 'obstacle';
  static const String hazardTypeClosedRoad = 'closed_road';
  static const String hazardTypeLaneBlocked = 'lane_blocked';
  
  // Severity Levels
  static const String severityLow = 'low';
  static const String severityMedium = 'medium';
  static const String severityHigh = 'high';
  static const String severityCritical = 'critical';
  
  // Sensor Settings
  static const int maxStoredCaptures = 20; // Limit stored captures
  
  // Camera Settings
  // Maximum performance - lowest quality for best FPS
  static const int imageQuality = 50; // Minimum quality for speed
  static const int maxImageWidth = 640; // Minimum resolution
  static const int maxImageHeight = 480; // Minimum resolution
  
  // Notification Settings
  static const String notificationChannelId = 'hazard_alerts';
  static const String notificationChannelName = 'Hazard Alerts';
  static const String notificationChannelDescription = 'Notifications for nearby road hazards';
  
  // Storage Keys
  static const String keyUserProfile = 'user_profile';
  static const String keySettings = 'app_settings';
  static const String keyHazardCache = 'hazard_cache';
  static const String keyDamageScore = 'cumulative_damage_score';
  static const String keyCapturedHazards = 'captured_hazards';
  static const String capturedHazardFolder = 'captured_hazards';
  
  // Vehicle Damage Tracking
  static const int damageScoreThreshold = 850; // Points before maintenance alert
  static const int maintenanceCheckInterval = 90; // Days between suggested checks
  
  // Fleet Analytics (for future B2B)
  static const int fleetSyncIntervalMinutes = 30;
  
  // Multi-signature verification
  static const int minReportsForVerification = 3; // k value for tamper-proof system
  
  // Voice Assistant Settings
  static const double voiceWarningDistanceMeters = 500.0; // Trigger voice warning at 500m
  static const double voiceWarningMinDistance = 50.0; // Don't warn if hazard is passed
  static const int voiceWarningCooldownSeconds = 30; // Don't repeat warning for same hazard within 30s
  static const String defaultVoiceLanguage = 'en'; // Default to English
  static const String keyVoiceLanguagePreference = 'voice_language_preference';
  static const String keyVoiceAssistantEnabled = 'voice_assistant_enabled';
  
  // ElevenLabs API Configuration
  // The API key is loaded from environment variables using flutter_dotenv.
  // Make sure to call `await dotenv.load()` in `main()` before using this value.
  static String get elevenLabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  
  // Google Maps API Key
  static const String googleMapsApiKey = 'AIzaSyA3JE25gHOK7B7Kd5LkAba0RLQv74pyTak';
  
  // Error Messages
  static const String errorNoInternet = 'No internet connection';
  static const String errorLocationPermission = 'Location permission required';
  static const String errorCameraPermission = 'Camera permission required';
  static const String errorGeneric = 'Something went wrong. Please try again.';
}
