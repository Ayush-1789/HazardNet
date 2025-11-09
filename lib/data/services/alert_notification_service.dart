import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:event_safety_app/data/services/elevenlabs_tts_service.dart';
import 'package:event_safety_app/data/services/alert_api_service.dart';
import 'package:event_safety_app/models/alert_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Enhanced Alert Notification Service with TTS integration
/// Monitors user location and provides voice alerts for nearby hazards
class AlertNotificationService {
  final AlertApiService _alertApiService;
  final ElevenLabsTTSService? _ttsService;
  
  StreamSubscription<Position>? _locationSubscription;
  Timer? _periodicCheckTimer;
  
  // Alert settings
  bool _isEnabled = true;
  bool _isTTSEnabled = true;
  String _selectedLanguage = 'en';
  double _alertRadius = 1.0; // km
  int _checkInterval = 30; // seconds
  
  // Alert cooldown to prevent spam
  final Map<String, DateTime> _alertCooldown = {};
  final Duration _cooldownDuration = const Duration(minutes: 5);
  
  // Severity-based alert messages
  static const Map<String, Map<String, String>> _alertMessages = {
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
      'accident': 'Accident reported ahead, proceed with caution',
      'emergency': 'Emergency situation ahead',
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
      'accident': 'आगे दुर्घटना की सूचना, सावधानी से आगे बढ़ें',
      'emergency': 'आगे आपातकालीन स्थिति',
    },
  };
  
  AlertNotificationService({
    AlertApiService? alertApiService,
    bool enableTTS = true,
  }) : _alertApiService = alertApiService ?? AlertApiService(),
       _ttsService = enableTTS && dotenv.env['ELEVENLABS_API_KEY'] != null
           ? ElevenLabsTTSService(apiKey: dotenv.env['ELEVENLABS_API_KEY']!)
           : null;
  
  /// Start monitoring for alerts
  Future<void> startMonitoring() async {
    if (!_isEnabled) return;
    
    debugPrint('🔔 [ALERT-SERVICE] Starting alert monitoring...');
    
    // Start location-based monitoring
    _startLocationMonitoring();
    
    // Start periodic check for new alerts
    _startPeriodicCheck();
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    debugPrint('🔔 [ALERT-SERVICE] Stopping alert monitoring...');
    _locationSubscription?.cancel();
    _periodicCheckTimer?.cancel();
  }
  
  /// Start location-based monitoring
  void _startLocationMonitoring() async {
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Check every 100 meters
      );
      
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _checkProximityAlerts(position.latitude, position.longitude);
      });
      
      debugPrint('✅ [ALERT-SERVICE] Location monitoring started');
    } catch (e) {
      debugPrint('❌ [ALERT-SERVICE] Location monitoring error: $e');
    }
  }
  
  /// Start periodic check for new alerts
  void _startPeriodicCheck() {
    _periodicCheckTimer = Timer.periodic(
      Duration(seconds: _checkInterval),
      (_) async {
        try {
          final position = await Geolocator.getCurrentPosition();
          await _checkProximityAlerts(position.latitude, position.longitude);
        } catch (e) {
          debugPrint('❌ [ALERT-SERVICE] Periodic check error: $e');
        }
      },
    );
    
    debugPrint('✅ [ALERT-SERVICE] Periodic check started (${_checkInterval}s interval)');
  }
  
  /// Check for proximity alerts
  Future<void> _checkProximityAlerts(double latitude, double longitude) async {
    try {
      debugPrint('🔍 [ALERT-SERVICE] Checking proximity alerts at ($latitude, $longitude)');
      
      final alerts = await _alertApiService.getProximityAlerts(
        latitude: latitude,
        longitude: longitude,
      );
      
      if (alerts.isEmpty) {
        debugPrint('✅ [ALERT-SERVICE] No proximity alerts found');
        return;
      }
      
      debugPrint('⚠️ [ALERT-SERVICE] Found ${alerts.length} proximity alerts');
      
      // Process each alert
      for (final alert in alerts) {
        await _processAlert(alert);
      }
    } catch (e) {
      debugPrint('❌ [ALERT-SERVICE] Proximity check error: $e');
    }
  }
  
  /// Process and announce an alert
  Future<void> _processAlert(AlertModel alert) async {
    try {
      // Check cooldown
      if (_isInCooldown(alert.id)) {
        debugPrint('⏳ [ALERT-SERVICE] Alert ${alert.id} in cooldown, skipping');
        return;
      }
      
      // Get alert message
      final message = _getAlertMessage(alert);
      
      debugPrint('📢 [ALERT-SERVICE] Processing alert: $message');
      
      // Speak alert if TTS is enabled
      if (_isTTSEnabled && _ttsService != null) {
        final success = await _ttsService!.speak(
          message,
          languageCode: _selectedLanguage,
        );
        
        if (success) {
          debugPrint('🔊 [ALERT-SERVICE] TTS alert announced');
        } else {
          debugPrint('❌ [ALERT-SERVICE] TTS announcement failed');
        }
      }
      
      // Add to cooldown
      _alertCooldown[alert.id] = DateTime.now();
      
      // Clean old cooldowns
      _cleanCooldowns();
    } catch (e) {
      debugPrint('❌ [ALERT-SERVICE] Alert processing error: $e');
    }
  }
  
  /// Get alert message in selected language
  String _getAlertMessage(AlertModel alert) {
    final languageMessages = _alertMessages[_selectedLanguage] ?? _alertMessages['en']!;
    
    // Try to get specific message for hazard type
    String message = languageMessages[alert.type] ?? alert.message;
    
    // Add severity prefix for critical alerts
    if (alert.severity == 'critical' || alert.severity == 'emergency') {
      if (_selectedLanguage == 'hi') {
        message = 'अत्यावश्यक! $message';
      } else {
        message = 'URGENT! $message';
      }
    }
    
    // Add distance information if available
    if (alert.metadata != null && alert.metadata!['distance'] != null) {
      final distance = alert.metadata!['distance'];
      if (_selectedLanguage == 'hi') {
        message = '$message, $distance किलोमीटर आगे';
      } else {
        message = '$message, $distance kilometers ahead';
      }
    }
    
    return message;
  }
  
  /// Check if alert is in cooldown period
  bool _isInCooldown(String alertId) {
    if (!_alertCooldown.containsKey(alertId)) return false;
    
    final lastAlert = _alertCooldown[alertId]!;
    final timeSinceLastAlert = DateTime.now().difference(lastAlert);
    
    return timeSinceLastAlert < _cooldownDuration;
  }
  
  /// Clean expired cooldowns
  void _cleanCooldowns() {
    final now = DateTime.now();
    _alertCooldown.removeWhere((key, value) {
      return now.difference(value) > _cooldownDuration;
    });
  }
  
  /// Manually announce an alert with TTS
  Future<bool> announceAlert(String message, {String? languageCode}) async {
    if (_ttsService == null) {
      debugPrint('❌ [ALERT-SERVICE] TTS service not available');
      return false;
    }
    
    return await _ttsService!.speak(
      message,
      languageCode: languageCode ?? _selectedLanguage,
    );
  }
  
  /// Update settings
  void updateSettings({
    bool? enabled,
    bool? ttsEnabled,
    String? language,
    double? alertRadius,
    int? checkInterval,
  }) {
    if (enabled != null) _isEnabled = enabled;
    if (ttsEnabled != null) _isTTSEnabled = ttsEnabled;
    if (language != null) _selectedLanguage = language;
    if (alertRadius != null) _alertRadius = alertRadius;
    if (checkInterval != null) {
      _checkInterval = checkInterval;
      // Restart periodic check with new interval
      if (_periodicCheckTimer != null && _periodicCheckTimer!.isActive) {
        stopMonitoring();
        startMonitoring();
      }
    }
    
    debugPrint('⚙️ [ALERT-SERVICE] Settings updated: enabled=$_isEnabled, tts=$_isTTSEnabled, lang=$_selectedLanguage');
  }
  
  /// Get current settings
  Map<String, dynamic> getSettings() {
    return {
      'enabled': _isEnabled,
      'ttsEnabled': _isTTSEnabled,
      'language': _selectedLanguage,
      'alertRadius': _alertRadius,
      'checkInterval': _checkInterval,
    };
  }
  
  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return ElevenLabsTTSService.getSupportedLanguages();
  }
  
  /// Get language name
  static String getLanguageName(String languageCode) {
    return ElevenLabsTTSService.getLanguageName(languageCode);
  }
  
  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _ttsService?.dispose();
  }
}
