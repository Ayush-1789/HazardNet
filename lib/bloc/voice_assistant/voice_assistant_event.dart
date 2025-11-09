import 'package:equatable/equatable.dart';
import 'package:event_safety_app/models/hazard_model.dart';

/// Events for Voice Assistant BLoC
abstract class VoiceAssistantEvent extends Equatable {
  const VoiceAssistantEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize voice assistant with language preference
class InitializeVoiceAssistant extends VoiceAssistantEvent {
  final String languageCode;
  final bool enabled;
  
  const InitializeVoiceAssistant({
    required this.languageCode,
    this.enabled = true,
  });
  
  @override
  List<Object?> get props => [languageCode, enabled];
}

/// Enable voice assistant
class EnableVoiceAssistant extends VoiceAssistantEvent {}

/// Disable voice assistant
class DisableVoiceAssistant extends VoiceAssistantEvent {}

/// Change voice language
class ChangeVoiceLanguage extends VoiceAssistantEvent {
  final String languageCode;
  
  const ChangeVoiceLanguage(this.languageCode);
  
  @override
  List<Object?> get props => [languageCode];
}

/// Check proximity to hazards and trigger warning if needed
class CheckHazardProximity extends VoiceAssistantEvent {
  final double userLatitude;
  final double userLongitude;
  final List<HazardModel> nearbyHazards;
  
  const CheckHazardProximity({
    required this.userLatitude,
    required this.userLongitude,
    required this.nearbyHazards,
  });
  
  @override
  List<Object?> get props => [userLatitude, userLongitude, nearbyHazards];
}

/// Manually trigger a test warning
class TestVoiceWarning extends VoiceAssistantEvent {
  final String? customMessage;
  
  const TestVoiceWarning({this.customMessage});
  
  @override
  List<Object?> get props => [customMessage];
}

/// Stop current voice playback
class StopVoicePlayback extends VoiceAssistantEvent {}
