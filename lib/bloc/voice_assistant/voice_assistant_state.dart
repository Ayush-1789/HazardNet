import 'package:equatable/equatable.dart';

/// States for Voice Assistant BLoC
abstract class VoiceAssistantState extends Equatable {
  const VoiceAssistantState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VoiceAssistantInitial extends VoiceAssistantState {}

/// Voice assistant ready
class VoiceAssistantReady extends VoiceAssistantState {
  final bool enabled;
  final String languageCode;
  final String? lastWarningHazardId;
  final DateTime? lastWarningTime;
  
  const VoiceAssistantReady({
    required this.enabled,
    required this.languageCode,
    this.lastWarningHazardId,
    this.lastWarningTime,
  });
  
  @override
  List<Object?> get props => [enabled, languageCode, lastWarningHazardId, lastWarningTime];
  
  VoiceAssistantReady copyWith({
    bool? enabled,
    String? languageCode,
    String? lastWarningHazardId,
    DateTime? lastWarningTime,
    bool clearLastWarning = false,
  }) {
    return VoiceAssistantReady(
      enabled: enabled ?? this.enabled,
      languageCode: languageCode ?? this.languageCode,
      lastWarningHazardId: clearLastWarning ? null : (lastWarningHazardId ?? this.lastWarningHazardId),
      lastWarningTime: clearLastWarning ? null : (lastWarningTime ?? this.lastWarningTime),
    );
  }
}

/// Voice is currently speaking
class VoiceAssistantSpeaking extends VoiceAssistantState {
  final String message;
  final String hazardId;
  final String languageCode;
  
  const VoiceAssistantSpeaking({
    required this.message,
    required this.hazardId,
    required this.languageCode,
  });
  
  @override
  List<Object?> get props => [message, hazardId, languageCode];
}

/// Error state
class VoiceAssistantError extends VoiceAssistantState {
  final String message;
  
  const VoiceAssistantError(this.message);
  
  @override
  List<Object?> get props => [message];
}
