# Multi-Lingual Voice Assistant for HazardNet

## Overview

The voice assistant provides real-time voice warnings in multiple Indian languages when users approach reported hazards (potholes, speed breakers, obstacles, etc.).

## Features

- **11 Supported Languages**: English, Hindi, Tamil, Telugu, Bengali, Marathi, Gujarati, Kannada, Malayalam, Punjabi, and Urdu
- **Smart Proximity Detection**: Warns users when within 500m of a hazard
- **Distance-Based Messages**: Different warning messages based on proximity (500m, 200m, 50m, immediate)
- **Cooldown System**: Prevents repetitive warnings for the same hazard (30-second cooldown)
- **High-Quality TTS**: Uses ElevenLabs API for natural-sounding voices in all languages

## Setup Instructions

### 1. Get ElevenLabs API Key

1. Sign up at [ElevenLabs](https://elevenlabs.io/)
2. Navigate to your profile settings
3. Copy your API key

### 2. Configure API Key

Open `lib/core/constants/app_constants.dart` and replace the placeholder:

```dart
static const String elevenLabsApiKey = 'YOUR_ELEVENLABS_API_KEY_HERE';
```

**Security Note**: For production, move this to environment variables:
- Create a `.env` file in the root directory
- Add: `ELEVENLABS_API_KEY=your_actual_key`
- Load using `flutter_dotenv` package

### 3. Install Dependencies

Run:
```bash
flutter pub get
```

This will install the required `audioplayers` package.

### 4. Configure Voice IDs (Optional)

The default voice IDs in `lib/data/services/elevenlabs_tts_service.dart` use ElevenLabs' multilingual voices. To customize:

1. Log into ElevenLabs
2. Browse the voice library for each language
3. Copy the voice IDs
4. Update the `_languageVoiceIds` map in `elevenlabs_tts_service.dart`

## Usage

### Initialization

The voice assistant is automatically initialized when the app starts. It loads the user's preferred language from settings.

### In Settings Screen

Add the voice assistant settings widget to your settings screen:

```dart
import 'package:event_safety_app/widgets/voice_assistant_settings.dart';

// In your settings screen build method:
VoiceAssistantSettings(),
```

This provides:
- Toggle to enable/disable voice assistant
- Language selection
- Test voice button

### Integration with Location Tracking

The voice assistant needs to be integrated with your location tracking to monitor proximity to hazards:

```dart
// In your LocationBloc or similar
final voiceBloc = context.read<VoiceAssistantBloc>();

// When location updates
voiceBloc.add(CheckHazardProximity(
  userLatitude: currentLat,
  userLongitude: currentLon,
  nearbyHazards: hazardsFromAPI,
));
```

### Programmatic Control

```dart
// Enable voice assistant
context.read<VoiceAssistantBloc>().add(EnableVoiceAssistant());

// Disable voice assistant
context.read<VoiceAssistantBloc>().add(DisableVoiceAssistant());

// Change language
context.read<VoiceAssistantBloc>().add(ChangeVoiceLanguage('hi')); // Hindi

// Test warning
context.read<VoiceAssistantBloc>().add(TestVoiceWarning());

// Stop current playback
context.read<VoiceAssistantBloc>().add(StopVoicePlayback());
```

## Warning Messages

### Distance-Based Warnings

- **Far (> 400m)**: "Caution! {hazard} ahead in {distance} meters"
- **Medium (200-400m)**: "Warning! {hazard} in {distance} meters. Please slow down"
- **Near (50-200m)**: "Attention! {hazard} very close, {distance} meters ahead"
- **Immediate (< 50m)**: "Alert! {hazard} right ahead. Be careful"

All messages are translated into the selected language automatically.

### Supported Hazard Types

- Pothole (गड्ढा in Hindi, குழி in Tamil, etc.)
- Speed Breaker
- Unmarked Speed Breaker
- Obstacle
- Closed Road
- Blocked Lane

## Customization

### Add New Languages

1. Add the language code and voice ID to `_languageVoiceIds` in `elevenlabs_tts_service.dart`
2. Add the language name to `languageNames`
3. Add translations to `_warningTemplates` and `_hazardTypeNames` in `voice_warning_templates.dart`

### Adjust Warning Distance

Edit `app_constants.dart`:

```dart
static const double voiceWarningDistanceMeters = 500.0; // Trigger distance
static const double voiceWarningMinDistance = 50.0; // Don't warn if passed
static const int voiceWarningCooldownSeconds = 30; // Cooldown between warnings
```

### Custom Warning Messages

Edit `lib/core/constants/voice_warning_templates.dart`:

```dart
static const Map<String, Map<String, String>> _warningTemplates = {
  'en': {
    'far': 'Your custom message with {hazard} and {distance}',
    // ...
  },
  // ...
};
```

## Architecture

### Components

1. **ElevenLabsTTSService**: Handles TTS API calls and audio playback
2. **VoiceAssistantBloc**: Manages state, proximity detection, and warning logic
3. **VoiceWarningTemplates**: Provides localized warning messages
4. **VoiceAssistantSettings**: UI widget for user preferences

### Flow

```
User Location Update
  ↓
LocationBloc sends CheckHazardProximity event
  ↓
VoiceAssistantBloc calculates distances to hazards
  ↓
If hazard within range and cooldown expired:
  ↓
Generate localized warning message
  ↓
Call ElevenLabs API to generate speech
  ↓
Play audio through audioplayers
  ↓
Record warning in history (cooldown)
```

## Testing

### Test Voice Warning

```dart
// Play test warning in current language
context.read<VoiceAssistantBloc>().add(TestVoiceWarning());

// Play custom test message
context.read<VoiceAssistantBloc>().add(
  TestVoiceWarning(customMessage: 'Test message in current language'),
);
```

### Debug Logs

The voice assistant includes detailed debug logging:

```
🔊 [VoiceAssistant] Initialized - Enabled: true, Language: hi
🔊 [VoiceAssistant] Warning for pothole at 250m
🔊 [VoiceAssistant] Message: चेतावनी! 250 मीटर में गड्ढा। कृपया धीमे चलें
✅ [TTS] Generated 45621 bytes of audio
✅ [TTS] Playing audio from /path/to/temp/tts_123456789.mp3
```

## Performance Considerations

- **API Calls**: Voice warnings trigger API calls to ElevenLabs. Each call consumes characters from your quota.
- **Cooldown**: 30-second cooldown prevents excessive API usage for the same hazard.
- **Caching**: Consider implementing audio caching for frequently used messages to reduce API calls.
- **Network**: Requires internet connection for TTS generation. Consider fallback to system TTS for offline mode.

## Troubleshooting

### No Audio Playing

1. Check that the device volume is up
2. Verify ElevenLabs API key is correct
3. Check internet connection
4. View debug logs for API errors

### Wrong Language/Voice

1. Verify the voice ID in `_languageVoiceIds` matches your ElevenLabs account
2. Test with the default voice IDs first
3. Check that `eleven_multilingual_v2` model supports your language

### Warnings Not Triggering

1. Ensure voice assistant is enabled in settings
2. Check that hazards are within 500m range
3. Verify cooldown hasn't prevented warning
4. Check that `CheckHazardProximity` events are being sent

## Future Enhancements

- [ ] Audio caching to reduce API calls
- [ ] Offline mode with system TTS fallback
- [ ] Custom voice speed/pitch settings
- [ ] Warning priority levels
- [ ] Navigation-aware warnings (only warn if hazard is on route)
- [ ] More languages (regional dialects)
- [ ] Male/Female voice selection per language

## License

Part of HazardNet - See main project LICENSE
