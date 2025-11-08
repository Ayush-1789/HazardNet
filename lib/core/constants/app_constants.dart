/// App-wide constants for HazardNet application
class AppConstants {
  // App Info
  static const String appName = 'HazardNet';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // TODO: Replace with your actual backend URL after deploying the backend
  // For local development on same PC: 'http://localhost:3000/api'
  // For mobile device on same network: 'http://192.168.31.39:3000/api'
  // For production: 'https://your-backend.vercel.app/api'
  static const String baseApiUrl = 'http://192.168.31.39:3000/api';
  
  // Authentication Endpoints
  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authLogoutEndpoint = '/auth/logout';
  static const String authCheckEndpoint = '/auth/check';
  
  // Hazard Endpoints
  static const String hazardsEndpoint = '/hazards';
  static const String nearbyHazardsEndpoint = '/hazards/nearby';
  static const String verifyHazardEndpoint = '/hazards/:id/verify';
  static const String reportHazardEndpoint = '/hazards/report';
  
  // Alert Endpoints
  static const String alertsEndpoint = '/alerts';
  static const String markAlertReadEndpoint = '/alerts/:id/read';
  
  // User Endpoints
  static const String userProfileEndpoint = '/users/profile';
  static const String updateDamageScoreEndpoint = '/users/damage-score';
  static const String userStatsEndpoint = '/users/stats';
  
  // Trip Endpoints
  static const String startTripEndpoint = '/trips/start';
  static const String endTripEndpoint = '/trips/end';
  static const String tripHistoryEndpoint = '/trips/history';
  
  // Sensor Data Endpoint
  static const String sensorDataEndpoint = '/sensor-data';
  
  // ML Model Endpoint (separate service)
  static const String mlApiUrl = 'http://localhost:5000';
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
  static const int gyroscopeUpdateIntervalMs = 100;
  static const int accelerometerUpdateIntervalMs = 100;
  static const double impactThresholdG = 2.0; // G-force threshold for impact detection
  
  // Camera Settings
  static const int imageQuality = 85;
  static const int maxImageWidth = 1280;
  static const int maxImageHeight = 720;
  
  // Notification Settings
  static const String notificationChannelId = 'hazard_alerts';
  static const String notificationChannelName = 'Hazard Alerts';
  static const String notificationChannelDescription = 'Notifications for nearby road hazards';
  
  // Storage Keys
  static const String keyUserProfile = 'user_profile';
  static const String keySettings = 'app_settings';
  static const String keyHazardCache = 'hazard_cache';
  static const String keyDamageScore = 'cumulative_damage_score';
  
  // Vehicle Damage Tracking
  static const int damageScoreThreshold = 850; // Points before maintenance alert
  static const int maintenanceCheckInterval = 90; // Days between suggested checks
  
  // Fleet Analytics (for future B2B)
  static const int fleetSyncIntervalMinutes = 30;
  
  // Multi-signature verification
  static const int minReportsForVerification = 3; // k value for tamper-proof system
  
  // Error Messages
  static const String errorNoInternet = 'No internet connection';
  static const String errorLocationPermission = 'Location permission required';
  static const String errorCameraPermission = 'Camera permission required';
  static const String errorGeneric = 'Something went wrong. Please try again.';
}
