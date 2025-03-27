import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/shift_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shift_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import 'request_shift_change_screen.dart';
import 'manage_shift_offers_screen.dart';

class ShiftDetailScreen extends StatelessWidget {
  final ShiftModel shift;
  
  const ShiftDetailScreen({
    Key? key,
    required this.shift,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;
    final isAssignedToMe = authProvider.user?.id == shift.assignedToId;
    final canRequestChange = isAssignedToMe && shift.status == 'assigned' && shift.date.isAfter(DateTime.now());
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Shift Details',
        actions: isOwner ? [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDeleteShift(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Shift', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: shift.date.isAfter(DateTime.now()) 
                        ? AppColors.primary.withOpacity(0.2) 
                        : AppColors.inactive.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shift.date.isAfter(DateTime.now()) ? 'Upcoming' : 'Past',
                    style: AppTextStyles.caption.copyWith(
                      color: shift.date.isAfter(DateTime.now()) 
                          ? AppColors.primary 
                          : AppColors.inactive,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(shift),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Event Name
            Text(
              shift.eventName,
              style: AppTextStyles.headline1,
            ),
            
            const SizedBox(height: 8),
            
            // Shift Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, dd.MM.yyyy').format(shift.date),
                  style: AppTextStyles.subtitle2,
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Shift Time
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(shift.date),
                  style: AppTextStyles.subtitle2,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Shift Type
            Text(
              'Shift Type',
              style: AppTextStyles.headline3,
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(
                  Icons.work,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  shift.shiftType,
                  style: AppTextStyles.subtitle1,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Assigned To
            Text(
              'Assigned To',
              style: AppTextStyles.headline3,
            ),
            
            const SizedBox(height: 8),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: AppColors.onPrimary),
              ),
              title: Text(shift.assignedToName, style: AppTextStyles.subtitle2),
              subtitle: Text('ID: ${shift.assignedToId}', style: AppTextStyles.caption),
            ),
            
            // Original Assigned To (if changed)
            if (shift.originalAssignedToName != null) ...[
              const SizedBox(height: 16),
              
              Text(
                'Originally Assigned To',
                style: AppTextStyles.headline3,
              ),
              
              const SizedBox(height: 8),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.inactive,
                  child: Icon(Icons.person, color: AppColors.onPrimary),
                ),
                title: Text(shift.originalAssignedToName!, style: AppTextStyles.subtitle2),
                subtitle: Text('ID: ${shift.originalAssignedToId}', style: AppTextStyles.caption),
              ),
            ],
            
            // Change Request Reason (if requested)
            if (shift.status == 'requested_change' && shift.changeRequestReason != null) ...[
              const SizedBox(height: 24),
              
              Text(
                'Change Request Reason',
                style: AppTextStyles.headline3,
              ),
              
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Text(
                  shift.changeRequestReason!,
                  style: AppTextStyles.bodyText1,
                ),
              ),
            ],
            
            // Change Offers (if any)
            if (shift.status == 'requested_change' && shift.changeOffers != null && shift.changeOffers!.isNotEmpty) ...[
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Offers',
                    style: AppTextStyles.headline3,
                  ),
                  if (isOwner)
                    TextButton(
                      onPressed: () => _navigateToManageOffers(context),
                      child: Text(
                        'Manage Offers',
                        style: AppTextStyles.button.copyWith(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shift.changeOffers!.length,
                itemBuilder: (context, index) {
                  final offer = shift.changeOffers![index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      child: Icon(Icons.person, color: AppColors.onSecondary),
                    ),
                    title: Text(offer.userName, style: AppTextStyles.subtitle2),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${offer.userId}', style: AppTextStyles.caption),
                        if (offer.message != null && offer.message!.isNotEmpty)
                          Text('Message: ${offer.message}', style: AppTextStyles.caption),
                      ],
                    ),
                    trailing: Text(
                      DateFormat('dd.MM.yyyy').format(offer.offerDate),
                      style: AppTextStyles.caption,
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Action Buttons
            if (canRequestChange)
              CustomButton(
                text: 'Request Shift Change',
                icon: Icons.swap_horiz,
                onPressed: () => _navigateToRequestChange(context),
              )
            else if (shift.status == 'requested_change' && !isAssignedToMe && !isOwner)
              CustomButton(
                text: 'Offer to Take Shift',
                icon: Icons.add_task,
                onPressed: () => _showOfferDialog(context),
              )
            else if (isOwner && shift.status == 'requested_change')
              CustomButton(
                text: 'Manage Change Requests',
                icon: Icons.manage_accounts,
                onPressed: () => _navigateToManageOffers(context),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(ShiftModel shift) {
    Color color;
    String text;
    
    switch (shift.status) {
      case 'requested_change':
        color = AppColors.warning;
        text = 'Change Requested';
        break;
      case 'change_approved':
        color = AppColors.success;
        text = 'Change Approved';
        break;
      case 'assigned':
      default:
        color = AppColors.info;
        text = 'Assigned';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _navigateToRequestChange(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestShiftChangeScreen(shift: shift),
      ),
    );
  }
  
  void _navigateToManageOffers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageShiftOffersScreen(shift: shift),
      ),
    );
  }
  
  Future<void> _showOfferDialog(BuildContext context) async {
    final TextEditingController messageController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Offer to Take Shift',
          style: AppTextStyles.headline3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to offer to take this shift?',
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Add a message (optional)',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _offerToTakeShift(
                context,
                authProvider.user!.id,
                authProvider.user!.name,
                messageController.text.isEmpty ? null : messageController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Submit Offer',
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _offerToTakeShift(BuildContext context, String userId, String userName, String? message) async {
    try {
      final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
      await shiftProvider.offerToTakeShift(shift.id, userId, userName, message);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer submitted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit offer: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _confirmDeleteShift(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Shift',
      message: 'Are you sure you want to delete this shift? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );
    
    if (confirmed) {
      _deleteShift(context);
    }
  }
  
  Future<void> _deleteShift(BuildContext context) async {
    try {
      final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
      await shiftProvider.deleteShift(shift.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shift deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete shift: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

