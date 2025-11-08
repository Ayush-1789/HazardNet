import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_safety_app/core/theme/app_colors.dart';
import 'package:event_safety_app/core/config/api_config.dart';
import 'package:event_safety_app/bloc/auth/auth_bloc.dart';
import 'package:event_safety_app/bloc/auth/auth_event.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings screen with app configuration options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _proximityAlertsEnabled = true;
  bool _autoReportEnabled = false;
  double _alertRadius = 1.0; // km
  String _appVersion = '';
  BackendType _selectedBackend = ApiConfig.currentBackendType;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'View and edit your profile',
            onTap: () {
              // Navigate to profile
            },
          ),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              // Navigate to change password
            },
          ),
          _buildListTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: AppColors.error,
            onTap: () => _handleLogout(context),
          ),
          
          const Divider(height: 32),
          
          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Enable Notifications',
            subtitle: 'Receive hazard alerts',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              print('🔔 [SETTINGS] Notifications: $value');
            },
          ),
          _buildSwitchTile(
            icon: Icons.volume_up_outlined,
            title: 'Sound',
            subtitle: 'Play alert sounds',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              print('🔊 [SETTINGS] Sound: $value');
            },
          ),
          _buildSwitchTile(
            icon: Icons.location_on_outlined,
            title: 'Proximity Alerts',
            subtitle: 'Alert when near hazards',
            value: _proximityAlertsEnabled,
            onChanged: (value) {
              setState(() => _proximityAlertsEnabled = value);
              print('📍 [SETTINGS] Proximity alerts: $value');
            },
          ),
          
          const Divider(height: 32),
          
          // Alert Settings
          _buildSectionHeader('Alert Settings'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.radar, color: AppColors.primary, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alert Radius',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_alertRadius.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _alertRadius,
                  min: 0.5,
                  max: 5.0,
                  divisions: 9,
                  label: '${_alertRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() => _alertRadius = value);
                    print('📏 [SETTINGS] Alert radius: ${value}km');
                  },
                ),
              ],
            ),
          ),
          _buildSwitchTile(
            icon: Icons.auto_mode,
            title: 'Auto-Report',
            subtitle: 'Automatically report detected hazards',
            value: _autoReportEnabled,
            onChanged: (value) {
              setState(() => _autoReportEnabled = value);
              print('🤖 [SETTINGS] Auto-report: $value');
            },
          ),
          
          const Divider(height: 32),
          
          // Backend Settings
          _buildSectionHeader('Backend Connection'),
          _buildRadioTile(
            icon: Icons.computer,
            title: 'Laptop Backend',
            subtitle: 'http://192.168.31.39:3000',
            value: BackendType.laptop,
            groupValue: _selectedBackend,
            onChanged: (value) {
              setState(() => _selectedBackend = value!);
              ApiConfig.useBackend(value!);
              print('🔌 [SETTINGS] Switched to Laptop backend');
              _showSnackBar('Switched to Laptop backend');
            },
          ),
          _buildRadioTile(
            icon: Icons.cloud,
            title: 'Render Cloud',
            subtitle: 'https://hazardnet-9yd2.onrender.com',
            value: BackendType.railway,
            groupValue: _selectedBackend,
            onChanged: (value) {
              setState(() => _selectedBackend = value!);
              ApiConfig.useBackend(value!);
              print('☁️ [SETTINGS] Switched to Render Cloud backend');
              _showSnackBar('Switched to Render Cloud backend');
            },
          ),
          _buildRadioTile(
            icon: Icons.cloud_outlined,
            title: 'Vercel Backup',
            subtitle: 'https://backend-92ppchxss...',
            value: BackendType.aws,
            groupValue: _selectedBackend,
            onChanged: (value) {
              setState(() => _selectedBackend = value!);
              ApiConfig.useBackend(value!);
              print('☁️ [SETTINGS] Switched to Vercel backup backend');
              _showSnackBar('Switched to Vercel backup');
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                _showSnackBar('Testing backend connection...');
                final backend = await ApiConfig.getAvailableBackendUrl();
                _showSnackBar('Connected to: $backend');
              },
              icon: const Icon(Icons.sync),
              label: const Text('Test Backend Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const Divider(height: 32),
          
          // App Info Section
          _buildSectionHeader('About'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: _appVersion.isNotEmpty ? _appVersion : 'Loading...',
          ),
          _buildListTile(
            icon: Icons.bug_report_outlined,
            title: 'Report Bug',
            subtitle: 'Help us improve',
            onTap: () {
              // Navigate to bug report
            },
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // Navigate to terms
            },
          ),
          
          const SizedBox(height: 32),
          
          // Debug Info
          Center(
            child: Text(
              'HazardNet for i.Mobilothon 5.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Current Backend: ${_getBackendName(_selectedBackend)}',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey400,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.grey600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildRadioTile<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  String _getBackendName(BackendType type) {
    switch (type) {
      case BackendType.laptop:
        return 'Laptop (Local)';
      case BackendType.railway:
        return 'Render Cloud';
      case BackendType.aws:
        return 'Vercel Backup';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
