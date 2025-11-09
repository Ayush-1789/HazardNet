import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Service for text-to-speech using ElevenLabs API
/// Supports multiple Indian languages for voice warnings
class ElevenLabsTTSService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  final String _apiKey;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // ElevenLabs voice IDs for different Indian languages
  // You'll need to configure these with actual voice IDs from your ElevenLabs account
  static const Map<String, String> _languageVoiceIds = {
    'en': 'EXAVITQu4vr4xnSDxMaL', // Default English voice (Bella)
    'hi': 'pNInz6obpgDQGcFmaJgB', // Hindi voice (Adam)
    'ta': 'ErXwobaYiN019PkySvjV', // Tamil voice (Antoni)
    'te': 'VR6AewLTigWG4xSOukaG', // Telugu voice (Arnold)
    'bn': 'pqHfZKP75CvOlQylNhV4', // Bengali voice (Bill)
    'mr': 'yoZ06aMxZJJ28mfd3POQ', // Marathi voice (Callum)
    'gu': 'N2lVS1w4EtoT3dr4eOWO', // Gujarati voice (Charlie)
    'kn': 'IKne3meq5aSn9XLyUdCD', // Kannada voice (Clyde)
    'ml': 'onwK4e9ZLuTAKqWW03F9', // Malayalam voice (Daniel)
    'pa': 'iP95p4xoKVk53GoZ742B', // Punjabi voice (Dave)
    'ur': 'cgSgspJ2msm6clMCkdW9', // Urdu voice (Ethan)
  };
  
  // Language names for UI display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी (Hindi)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'bn': 'বাংলা (Bengali)',
    'mr': 'मराठी (Marathi)',
    'gu': 'ગુજરાતી (Gujarati)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
    'ur': 'اردو (Urdu)',
  };
  
  ElevenLabsTTSService({required String apiKey}) : _apiKey = apiKey;
  
  /// Get list of supported languages
  static List<String> getSupportedLanguages() => _languageVoiceIds.keys.toList();
  
  /// Get language name for display
  static String getLanguageName(String languageCode) =>
      languageNames[languageCode] ?? languageCode;
  
  /// Convert text to speech and play it
  /// Returns true if successful, false otherwise
  Future<bool> speak(String text, {String languageCode = 'en'}) async {
    try {
      debugPrint('🔊 [TTS] Speaking in $languageCode: $text');
      
      // Get voice ID for the language
      final voiceId = _languageVoiceIds[languageCode] ?? _languageVoiceIds['en']!;
      
      // Generate speech
      final audioBytes = await _generateSpeech(text, voiceId);
      if (audioBytes == null) {
        debugPrint('❌ [TTS] Failed to generate speech');
        return false;
      }
      
      // Save to temporary file
      final tempFile = await _saveToTempFile(audioBytes);
      
      // Play audio
      await _audioPlayer.stop(); // Stop any current playback
      await _audioPlayer.play(DeviceFileSource(tempFile.path));
      
      debugPrint('✅ [TTS] Playing audio from ${tempFile.path}');
      return true;
    } catch (e) {
      debugPrint('❌ [TTS] Error: $e');
      return false;
    }
  }
  
  /// Generate speech from text using ElevenLabs API
  Future<List<int>?> _generateSpeech(String text, String voiceId) async {
    try {
      final url = Uri.parse('$_baseUrl/text-to-speech/$voiceId');
      
      final response = await http.post(
        url,
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2', // Supports multiple languages
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ [TTS] Generated ${response.bodyBytes.length} bytes of audio');
        return response.bodyBytes;
      } else {
        debugPrint('❌ [TTS] API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [TTS] Network error: $e');
      return null;
    }
  }
  
  /// Save audio bytes to temporary file
  Future<File> _saveToTempFile(List<int> audioBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await tempFile.writeAsBytes(audioBytes);
    return tempFile;
  }
  
  /// Stop current playback
  Future<void> stop() async {
    await _audioPlayer.stop();
  }
  
  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
