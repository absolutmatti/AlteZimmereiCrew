import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import 'user_management_screen.dart';
import 'statistics_screen.dart';
import 'system_settings_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;

    // Redirect non-owners
    if (!isOwner) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Admin',
          showBackButton: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: AppTextStyles.headline2,
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to access this area.',
                style: AppTextStyles.bodyText1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: AppColors.onPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: AppTextStyles.headline3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your crew and venue',
                          style: AppTextStyles.bodyText2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Management',
              style: AppTextStyles.headline3,
            ),
            
            const SizedBox(height: 16),
            
            // User Management
            _buildAdminCard(
              context,
              title: 'User Management',
              description: 'Manage crew members, roles, and permissions',
              icon: Icons.people,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserManagementScreen(),
                ),
              ),
            ),
            
            // Statistics
            _buildAdminCard(
              context,
              title: 'Statistics',
              description: 'View attendance, shifts, and time tracking data',
              icon: Icons.bar_chart,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              ),
            ),
            
            // System Settings
            _buildAdminCard(
              context,
              title: 'System Settings',
              description: 'Configure app settings and notifications',
              icon: Icons.settings,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SystemSettingsScreen(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Quick Actions',
              style: AppTextStyles.headline3,
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickActionCard(
                  context,
                  title: 'Add User',
                  icon: Icons.person_add,
                  color: AppColors.primary,
                  onTap: () {
                    // Navigate to add user screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Create Event',
                  icon: Icons.event_available,
                  color: AppColors.secondary,
                  onTap: () {
                    // Navigate to create event screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Approve Time',
                  icon: Icons.timer,
                  color: AppColors.info,
                  onTap: () {
                    // Navigate to time approval screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Send Notification',
                  icon: Icons.notifications_active,
                  color: AppColors.warning,
                  onTap: () {
                    // Navigate to send notification screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.inactive,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.inactive,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.subtitle2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

