import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_safety_app/bloc/voice_assistant/voice_assistant_event.dart';
import 'package:event_safety_app/bloc/voice_assistant/voice_assistant_state.dart';
import 'package:event_safety_app/data/services/elevenlabs_tts_service.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/core/constants/voice_warning_templates.dart';
import 'package:event_safety_app/models/hazard_model.dart';

/// BLoC for managing voice assistant functionality
class VoiceAssistantBloc extends Bloc<VoiceAssistantEvent, VoiceAssistantState> {
  final ElevenLabsTTSService _ttsService;
  final SharedPreferences _prefs;
  final Map<String, DateTime> _warningHistory = {}; // Track when each hazard was warned about
  bool _isSpeaking = false;
  
  VoiceAssistantBloc({
    required ElevenLabsTTSService ttsService,
    required SharedPreferences prefs,
  })  : _ttsService = ttsService,
        _prefs = prefs,
        super(VoiceAssistantInitial()) {
    on<InitializeVoiceAssistant>(_onInitialize);
    on<EnableVoiceAssistant>(_onEnable);
    on<DisableVoiceAssistant>(_onDisable);
    on<ChangeVoiceLanguage>(_onChangeLanguage);
    on<CheckHazardProximity>(_onCheckProximity);
    on<TestVoiceWarning>(_onTestWarning);
    on<StopVoicePlayback>(_onStopPlayback);
  }
  
  Future<void> _onInitialize(InitializeVoiceAssistant event, Emitter<VoiceAssistantState> emit) async {
    try {
      // Load saved preferences
      final enabled = _prefs.getBool(AppConstants.keyVoiceAssistantEnabled) ?? event.enabled;
      final languageCode = _prefs.getString(AppConstants.keyVoiceLanguagePreference) ?? event.languageCode;
      
      emit(VoiceAssistantReady(
        enabled: enabled,
        languageCode: languageCode,
      ));
      
      debugPrint('🔊 [VoiceAssistant] Initialized - Enabled: $enabled, Language: $languageCode');
    } catch (e) {
      debugPrint('❌ [VoiceAssistant] Initialization error: $e');
      emit(VoiceAssistantError('Failed to initialize voice assistant: $e'));
    }
  }
  
  Future<void> _onEnable(EnableVoiceAssistant event, Emitter<VoiceAssistantState> emit) async {
    if (state is VoiceAssistantReady) {
      await _prefs.setBool(AppConstants.keyVoiceAssistantEnabled, true);
      emit((state as VoiceAssistantReady).copyWith(enabled: true));
      debugPrint('🔊 [VoiceAssistant] Enabled');
    }
  }
  
  Future<void> _onDisable(DisableVoiceAssistant event, Emitter<VoiceAssistantState> emit) async {
    if (state is VoiceAssistantReady) {
      await _prefs.setBool(AppConstants.keyVoiceAssistantEnabled, false);
      await _ttsService.stop();
      emit((state as VoiceAssistantReady).copyWith(enabled: false));
      debugPrint('🔊 [VoiceAssistant] Disabled');
    }
  }
  
  Future<void> _onChangeLanguage(ChangeVoiceLanguage event, Emitter<VoiceAssistantState> emit) async {
    if (state is VoiceAssistantReady) {
      await _prefs.setString(AppConstants.keyVoiceLanguagePreference, event.languageCode);
      emit((state as VoiceAssistantReady).copyWith(languageCode: event.languageCode));
      debugPrint('🔊 [VoiceAssistant] Language changed to: ${event.languageCode}');
      
      // Test the new language
      add(TestVoiceWarning());
    }
  }
  
  Future<void> _onCheckProximity(CheckHazardProximity event, Emitter<VoiceAssistantState> emit) async {
    if (state is! VoiceAssistantReady) return;
    final readyState = state as VoiceAssistantReady;
    
    if (!readyState.enabled) return;

    if (_isSpeaking) {
      debugPrint('🔊 [VoiceAssistant] Already speaking — skipping proximity warning');
      return;
    }
    
    // Find closest hazard within warning distance
    HazardModel? closestHazard;
    double closestDistance = double.infinity;
    
    for (final hazard in event.nearbyHazards) {
      final distance = _calculateDistance(
        event.userLatitude,
        event.userLongitude,
        hazard.latitude,
        hazard.longitude,
      );
      
      // Check if within warning range
      if (distance <= AppConstants.voiceWarningDistanceMeters &&
          distance >= AppConstants.voiceWarningMinDistance &&
          distance < closestDistance) {
        closestHazard = hazard;
        closestDistance = distance;
      }
    }
    
    if (closestHazard == null) return;
    
    // Check if we've recently warned about this hazard
    final lastWarningTime = _warningHistory[closestHazard.id];
    if (lastWarningTime != null) {
      final timeSinceWarning = DateTime.now().difference(lastWarningTime).inSeconds;
      if (timeSinceWarning < AppConstants.voiceWarningCooldownSeconds) {
        return; // Too soon to warn again
      }
    }
    
    // Generate and speak warning
    final warningMessage = VoiceWarningTemplates.getProximityWarning(
      hazardType: closestHazard.type,
      distance: closestDistance.round(),
      languageCode: readyState.languageCode,
    );
    
    debugPrint('🔊 [VoiceAssistant] Warning for ${closestHazard.type} at ${closestDistance.round()}m');
    debugPrint('🔊 [VoiceAssistant] Message: $warningMessage');
    
    emit(VoiceAssistantSpeaking(
      message: warningMessage,
      hazardId: closestHazard.id,
      languageCode: readyState.languageCode,
    ));
    
    // Speak the warning (guard against overlapping speak calls)
    _isSpeaking = true;
    try {
      final success = await _ttsService.speak(
        warningMessage,
        languageCode: readyState.languageCode,
      );

      if (success) {
        // Record this warning
        _warningHistory[closestHazard.id] = DateTime.now();

        emit(readyState.copyWith(
          lastWarningHazardId: closestHazard.id,
          lastWarningTime: DateTime.now(),
        ));
      } else {
        emit(readyState);
        debugPrint('❌ [VoiceAssistant] Failed to speak warning');
      }
    } finally {
      _isSpeaking = false;
    }
  }
  
  Future<void> _onTestWarning(TestVoiceWarning event, Emitter<VoiceAssistantState> emit) async {
    if (state is! VoiceAssistantReady) return;
    final readyState = state as VoiceAssistantReady;
    
    final testMessage = event.customMessage ?? 
        VoiceWarningTemplates.getProximityWarning(
          hazardType: 'pothole',
          distance: 200,
          languageCode: readyState.languageCode,
        );
    
    debugPrint('🔊 [VoiceAssistant] Testing voice: $testMessage');
    
    emit(VoiceAssistantSpeaking(
      message: testMessage,
      hazardId: 'test',
      languageCode: readyState.languageCode,
    ));

    if (_isSpeaking) {
      debugPrint('🔊 [VoiceAssistant] Already speaking — skipping test voice');
      emit(readyState);
      return;
    }

    _isSpeaking = true;
    try {
      await _ttsService.speak(testMessage, languageCode: readyState.languageCode);
    } finally {
      _isSpeaking = false;
      emit(readyState);
    }
  }
  
  Future<void> _onStopPlayback(StopVoicePlayback event, Emitter<VoiceAssistantState> emit) async {
    await _ttsService.stop();
    if (state is VoiceAssistantReady) {
      emit(state as VoiceAssistantReady);
    }
  }
  
  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0; // meters
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
  
  @override
  Future<void> close() {
    _ttsService.dispose();
    return super.close();
  }
}
