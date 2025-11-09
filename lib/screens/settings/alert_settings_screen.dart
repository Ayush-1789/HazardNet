import 'package:flutter/material.dart';
import 'package:event_safety_app/core/theme/app_colors.dart';
import 'package:event_safety_app/data/services/alert_notification_service.dart';

/// Alert & TTS Settings Screen
/// Allows users to configure voice alerts and notification preferences
class AlertSettingsScreen extends StatefulWidget {
  final AlertNotificationService alertService;

  const AlertSettingsScreen({
    super.key,
    required this.alertService,
  });

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  late bool _alertsEnabled;
  late bool _ttsEnabled;
  late String _selectedLanguage;
  late double _alertRadius;
  late int _checkInterval;

  final List<double> _radiusOptions = [0.5, 1.0, 2.0, 5.0];
  final List<int> _intervalOptions = [15, 30, 60, 120];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = widget.alertService.getSettings();
    setState(() {
      _alertsEnabled = settings['enabled'] as bool;
      _ttsEnabled = settings['ttsEnabled'] as bool;
      _selectedLanguage = settings['language'] as String;
      _alertRadius = settings['alertRadius'] as double;
      _checkInterval = settings['checkInterval'] as int;
    });
  }

  void _updateSettings() {
    widget.alertService.updateSettings(
      enabled: _alertsEnabled,
      ttsEnabled: _ttsEnabled,
      language: _selectedLanguage,
      alertRadius: _alertRadius,
      checkInterval: _checkInterval,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _testTTS() async {
    final testMessages = {
      'en': 'Warning! Pothole detected ahead. Please slow down and drive carefully.',
      'hi': 'चेतावनी! आगे गड्ढा मिला है। कृपया धीमे चलें और सावधानी से गाड़ी चलाएं।',
      'ta': 'எச்சரிக்கை! முன்னால் குழி உள்ளது. மெதுவாக செல்லவும்.',
      'te': 'హెచ్చరిక! ముందు గొయ్యి ఉంది. నెమ్మదిగా వెళ్ళండి.',
      'bn': 'সতর্কতা! সামনে গর্ত আছে। ধীরে চলুন এবং সাবধানে গাড়ি চালান।',
      'mr': 'चेतावणी! पुढे खड्डा आहे. कृपया हळू जा.',
      'gu': 'ચેતવણી! આગળ ખાડો છે. કૃપા કરીને ધીમા ચાલો.',
      'kn': 'ಎಚ್ಚರಿಕೆ! ಮುಂದೆ ಗುಂಡಿ ಇದೆ. ದಯವಿಟ್ಟು ನಿಧಾನವಾಗಿ ಹೋಗಿ.',
      'ml': 'മുന്നറിയിപ്പ്! മുന്നിൽ കുഴി ഉണ്ട്. സാവധാനം പോകുക.',
      'pa': 'ਚੇਤਾਵਨੀ! ਅੱਗੇ ਟੋਆ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਹੌਲੀ ਚੱਲੋ।',
      'ur': 'انتباہ! آگے گڑھا ہے۔ براہ کرم آہستہ چلیں۔',
    };

    final message = testMessages[_selectedLanguage] ?? testMessages['en']!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Testing Voice Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Playing: $message'),
          ],
        ),
      ),
    );

    final success = await widget.alertService.announceAlert(message);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Test successful!' : 'Test failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert & Voice Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alerts Section
          _buildSectionHeader('Alert Notifications', Icons.notifications_active),
          _buildCard(
            isDark,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Alerts'),
                  subtitle: const Text('Receive proximity alerts for hazards'),
                  value: _alertsEnabled,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (value) {
                    setState(() => _alertsEnabled = value);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Alert Radius'),
                  subtitle: Text('${_alertRadius.toStringAsFixed(1)} km'),
                  leading: const Icon(Icons.location_on),
                  trailing: DropdownButton<double>(
                    value: _alertRadius,
                    items: _radiusOptions.map((radius) {
                      return DropdownMenuItem(
                        value: radius,
                        child: Text('${radius.toStringAsFixed(1)} km'),
                      );
                    }).toList(),
                    onChanged: _alertsEnabled ? (value) {
                      if (value != null) {
                        setState(() => _alertRadius = value);
                      }
                    } : null,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Check Interval'),
                  subtitle: Text('$_checkInterval seconds'),
                  leading: const Icon(Icons.timer),
                  trailing: DropdownButton<int>(
                    value: _checkInterval,
                    items: _intervalOptions.map((interval) {
                      return DropdownMenuItem(
                        value: interval,
                        child: Text('$interval sec'),
                      );
                    }).toList(),
                    onChanged: _alertsEnabled ? (value) {
                      if (value != null) {
                        setState(() => _checkInterval = value);
                      }
                    } : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Voice Alerts Section
          _buildSectionHeader('Voice Alerts (TTS)', Icons.record_voice_over),
          _buildCard(
            isDark,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Voice Alerts'),
                  subtitle: const Text('Speak alerts using text-to-speech'),
                  value: _ttsEnabled,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: _alertsEnabled ? (value) {
                    setState(() => _ttsEnabled = value);
                  } : null,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Voice Language'),
                  subtitle: Text(
                    AlertNotificationService.getLanguageName(_selectedLanguage),
                  ),
                  leading: const Icon(Icons.language),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: AlertNotificationService.getSupportedLanguages().map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(
                          AlertNotificationService.getLanguageName(lang),
                        ),
                      );
                    }).toList(),
                    onChanged: _alertsEnabled && _ttsEnabled ? (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    } : null,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Test Voice'),
                  subtitle: const Text('Play a sample alert'),
                  leading: const Icon(Icons.volume_up),
                  trailing: ElevatedButton.icon(
                    onPressed: _alertsEnabled && _ttsEnabled ? _testTTS : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info Section
          _buildSectionHeader('How it Works', Icons.info_outline),
          _buildCard(
            isDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem(
                    '🎯 Proximity Alerts',
                    'Get notified when hazards are detected within your selected radius',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    '🔊 Voice Warnings',
                    'Hear spoken alerts in your preferred language while driving',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    '⏰ Smart Cooldown',
                    'Prevents repeated alerts for the same hazard within 5 minutes',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    '🌍 Multi-language',
                    'Supports 11 Indian languages plus English',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Warning Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Voice alerts require an active internet connection and ElevenLabs API key',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
