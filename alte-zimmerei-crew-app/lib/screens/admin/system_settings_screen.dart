import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = true;
  bool _enableAutoCheckout = false;
  String _defaultShiftDuration = '8 hours';
  String _timeFormat = '24 hour';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'System Settings',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 16),
            _buildSettingSwitch(
              title: 'Push Notifications',
              subtitle: 'Enable push notifications for all users',
              value: _enablePushNotifications,
              onChanged: (value) {
                setState(() {
                  _enablePushNotifications = value;
                });
              },
            ),
            _buildSettingSwitch(
              title: 'Email Notifications',
              subtitle: 'Send email notifications for important updates',
              value: _enableEmailNotifications,
              onChanged: (value) {
                setState(() {
                  _enableEmailNotifications = value;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Time Tracking Settings',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 16),
            _buildSettingSwitch(
              title: 'Auto Checkout',
              subtitle: 'Automatically check out users at the end of their shift',
              value: _enableAutoCheckout,
              onChanged: (value) {
                setState(() {
                  _enableAutoCheckout = value;
                });
              },
            ),
            _buildSettingDropdown(
              title: 'Default Shift Duration',
              value: _defaultShiftDuration,
              options: const ['4 hours', '6 hours', '8 hours', '12 hours'],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _defaultShiftDuration = value;
                  });
                }
              },
            ),
            _buildSettingDropdown(
              title: 'Time Format',
              value: _timeFormat,
              options: const ['12 hour', '24 hour'],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _timeFormat = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Data Management',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              title: 'Export Data',
              subtitle: 'Export all data to CSV files',
              icon: Icons.download,
              onPressed: () {
                // Implement data export
              },
            ),
            _buildActionButton(
              title: 'Backup Database',
              subtitle: 'Create a backup of the entire database',
              icon: Icons.backup,
              onPressed: () {
                // Implement database backup
              },
            ),
            _buildActionButton(
              title: 'Clear Cache',
              subtitle: 'Clear temporary files and cache',
              icon: Icons.cleaning_services,
              onPressed: () {
                // Implement cache clearing
              },
            ),
            
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Save Settings',
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.subtitle2),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingDropdown({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.subtitle2),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(),
              ),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: ListTile(
        title: Text(title, style: AppTextStyles.subtitle2),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }

  void _saveSettings() {
    // Implement settings save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

