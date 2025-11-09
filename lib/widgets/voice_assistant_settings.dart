import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_safety_app/bloc/voice_assistant/voice_assistant_bloc.dart';
import 'package:event_safety_app/bloc/voice_assistant/voice_assistant_event.dart';
import 'package:event_safety_app/bloc/voice_assistant/voice_assistant_state.dart';
import 'package:event_safety_app/data/services/elevenlabs_tts_service.dart';
import 'package:event_safety_app/core/theme/app_colors.dart';

/// Voice Assistant Settings Widget
class VoiceAssistantSettings extends StatelessWidget {
  const VoiceAssistantSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceAssistantBloc, VoiceAssistantState>(
      builder: (context, state) {
        if (state is! VoiceAssistantReady) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voice Assistant Toggle
            SwitchListTile(
              title: const Text(
                'Voice Assistant',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                'Get voice warnings for nearby hazards',
              ),
              value: state.enabled,
              activeThumbColor: AppColors.primaryBlue,
              onChanged: (value) {
                if (value) {
                  context.read<VoiceAssistantBloc>().add(EnableVoiceAssistant());
                } else {
                  context.read<VoiceAssistantBloc>().add(DisableVoiceAssistant());
                }
              },
            ),

            if (state.enabled) ...[
              const Divider(),

              // Language Selection
              ListTile(
                title: const Text(
                  'Voice Language',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  ElevenLabsTTSService.getLanguageName(state.languageCode),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageSelector(context, state.languageCode),
              ),

              const Divider(),

              // Test Voice
              ListTile(
                leading: const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue),
                title: const Text('Test Voice Assistant'),
                subtitle: const Text('Hear a sample warning'),
                onTap: () {
                  context.read<VoiceAssistantBloc>().add(const TestVoiceWarning());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Playing test warning...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // Voice Assistant Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha:0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Voice warnings will be triggered when you are within 500m of a reported hazard.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context, String currentLanguage) {
    final languages = ElevenLabsTTSService.getSupportedLanguages();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Voice Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final languageCode = languages[index];
                  final languageName = ElevenLabsTTSService.getLanguageName(languageCode);
                  final isSelected = languageCode == currentLanguage;

                  return ListTile(
                    title: Text(
                      languageName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primaryBlue : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primaryBlue)
                        : null,
                    onTap: () {
                      context.read<VoiceAssistantBloc>().add(
                            ChangeVoiceLanguage(languageCode),
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
