import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/user_avatar.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _authService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'User Management',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading users...')
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: AppTextStyles.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Retry',
                        onPressed: _loadUsers,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? const EmptyState(
                      message: 'No users found',
                      icon: Icons.people,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return _buildUserCard(user);
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add user screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: user.profileImageUrl,
              name: user.name,
              size: 50,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.subtitle1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodyText2,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: user.isOwner()
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.isOwner() ? 'Owner' : 'Employee',
                      style: AppTextStyles.caption.copyWith(
                        color: user.isOwner() ? AppColors.primary : AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  // Navigate to edit user screen
                } else if (value == 'delete') {
                  _showDeleteConfirmation(user);
                } else if (value == 'change_role') {
                  _showChangeRoleDialog(user);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit User'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz),
                      SizedBox(width: 8),
                      Text('Change Role'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete User', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete User',
          style: AppTextStyles.headline3,
        ),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
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
              'Delete',
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete user
      // This would be implemented in the AuthService
    }
  }

  Future<void> _showChangeRoleDialog(UserModel user) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Change Role',
          style: AppTextStyles.headline3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a new role for ${user.name}:',
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Owner'),
              leading: Radio<String>(
                value: 'owner',
                groupValue: user.role,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
            ListTile(
              title: const Text('Employee'),
              leading: Radio<String>(
                value: 'employee',
                groupValue: user.role,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (newRole != null && newRole != user.role) {
      // Update user role
      // This would be implemented in the AuthService
    }
  }
}

