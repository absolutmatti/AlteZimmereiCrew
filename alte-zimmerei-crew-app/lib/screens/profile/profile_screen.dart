import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'notification_preferences_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.surface,
              child: Column(
                children: [
                  UserAvatar(
                    imageUrl: user.profileImageUrl,
                    name: user.name,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: AppTextStyles.headline2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.isOwner() ? 'Owner' : 'Crew Member',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: user.isOwner() ? AppColors.primary : AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Edit Profile',
                    icon: Icons.edit,
                    type: ButtonType.outline,
                    isFullWidth: false,
                    onPressed: () => _navigateToEditProfile(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Profile Info
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(Icons.email, 'Email', user.email),
                  if (user.phoneNumber != null)
                    _buildInfoItem(Icons.phone, 'Phone', user.phoneNumber!),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Settings
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    Icons.notifications,
                    'Notification Preferences',
                    () => _navigateToNotificationPreferences(context),
                  ),
                  _buildSettingsItem(
                    Icons.settings,
                    'App Settings',
                    () => _navigateToSettings(context),
                  ),
                  _buildSettingsItem(
                    Icons.logout,
                    'Logout',
                    () => _confirmLogout(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption,
              ),
              Text(
                value,
                style: AppTextStyles.bodyText1,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyText1.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive ? AppColors.error : AppColors.inactive,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }
  
  void _navigateToNotificationPreferences(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationPreferencesScreen(),
      ),
    );
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
  
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Logout',
          style: AppTextStyles.headline3,
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyText1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Logout',
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }
}

