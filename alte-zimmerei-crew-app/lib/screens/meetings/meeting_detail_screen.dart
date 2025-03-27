import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/meeting_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meeting_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import 'edit_meeting_screen.dart';
import 'upload_protocol_screen.dart';

class MeetingDetailScreen extends StatelessWidget {
  final MeetingModel meeting;
  
  const MeetingDetailScreen({
    Key? key,
    required this.meeting,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isCreator = authProvider.user?.id == meeting.createdById;
    final isOwner = authProvider.isOwner;
    final canEdit = isOwner || isCreator;
    final userId = authProvider.user?.id ?? '';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Meeting Details',
        actions: canEdit ? [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEditMeeting(context);
              } else if (value == 'delete') {
                _confirmDeleteMeeting(context);
              } else if (value == 'upload') {
                _navigateToUploadProtocol(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Meeting'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'upload',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Upload Protocol'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Meeting', style: TextStyle(color: AppColors.error)),
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
                    color: meeting.date.isAfter(DateTime.now()) 
                        ? AppColors.primary.withOpacity(0.2) 
                        : AppColors.inactive.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    meeting.date.isAfter(DateTime.now()) ? 'Upcoming' : 'Past',
                    style: AppTextStyles.caption.copyWith(
                      color: meeting.date.isAfter(DateTime.now()) 
                          ? AppColors.primary 
                          : AppColors.inactive,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildAttendanceStatusBadge(meeting, userId),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Meeting Title
            Text(
              meeting.title,
              style: AppTextStyles.headline1,
            ),
            
            const SizedBox(height: 8),
            
            // Meeting Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, dd.MM.yyyy').format(meeting.date),
                  style: AppTextStyles.subtitle2,
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Meeting Time
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(meeting.date),
                  style: AppTextStyles.subtitle2,
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Meeting Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  meeting.location,
                  style: AppTextStyles.subtitle2,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Meeting Description
            Text(
              'Description',
              style: AppTextStyles.headline3,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              meeting.description,
              style: AppTextStyles.bodyText1,
            ),
            
            const SizedBox(height: 24),
            
            // Protocol
            if (meeting.protocolUrl != null) ...[
              Text(
                'Protocol',
                style: AppTextStyles.headline3,
              ),
              
              const SizedBox(height: 8),
              
              InkWell(
                onTap: () => _openProtocol(meeting.protocolUrl!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'View Protocol',
                          style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.open_in_new,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Attendees Section
            Text(
              'Attendees',
              style: AppTextStyles.headline3,
            ),
            
            const SizedBox(height: 8),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meeting.attendees.length,
              itemBuilder: (context, index) {
                final entry = meeting.attendees.entries.elementAt(index);
                return _buildAttendeeItem(entry.key, entry.value);
              },
            ),
            
            const SizedBox(height: 32),
            
            // Attendance Actions
            if (meeting.date.isAfter(DateTime.now()) && meeting.attendees.containsKey(userId))
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Attending',
                      type: ButtonType.primary,
                      onPressed: () => _updateAttendanceStatus(context, userId, 'attending'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Not Attending',
                      type: ButtonType.outline,
                      onPressed: () => _showReasonDialog(context, userId),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceStatusBadge(MeetingModel meeting, String userId) {
    if (!meeting.attendees.containsKey(userId)) {
      return const SizedBox.shrink();
    }
    
    final status = meeting.attendees[userId]!.status;
    
    Color color;
    String text;
    
    switch (status) {
      case 'attending':
        color = AppColors.success;
        text = 'Attending';
        break;
      case 'not_attending':
        color = AppColors.error;
        text = 'Not Attending';
        break;
      case 'pending':
      default:
        color = AppColors.warning;
        text = 'Pending';
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
  
  Widget _buildAttendeeItem(String userId, AttendanceStatus status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.status) {
      case 'attending':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'not_attending':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.help;
        break;
    }
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, color: AppColors.onPrimary),
      ),
      title: Text('User ID: $userId', style: AppTextStyles.subtitle2),
      subtitle: status.reason != null && status.reason!.isNotEmpty
          ? Text('Reason: ${status.reason}', style: AppTextStyles.caption)
          : null,
      trailing: Icon(statusIcon, color: statusColor),
    );
  }
  
  void _navigateToEditMeeting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMeetingScreen(meeting: meeting),
      ),
    );
  }
  
  void _navigateToUploadProtocol(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadProtocolScreen(meetingId: meeting.id),
      ),
    );
  }
  
  Future<void> _confirmDeleteMeeting(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Meeting',
      message: 'Are you sure you want to delete this meeting? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );
    
    if (confirmed) {
      _deleteMeeting(context);
    }
  }
  
  Future<void> _deleteMeeting(BuildContext context) async {
    try {
      final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
      await meetingProvider.deleteMeeting(meeting.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete meeting: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _updateAttendanceStatus(BuildContext context, String userId, String status, {String? reason}) async {
    try {
      final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
      await meetingProvider.updateAttendanceStatus(meeting.id, userId, status, reason);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance status updated to $status'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update attendance status: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _showReasonDialog(BuildContext context, String userId) async {
    final TextEditingController reasonController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reason for Not Attending',
          style: AppTextStyles.headline3,
        ),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter your reason (optional)',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
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
              _updateAttendanceStatus(
                context, 
                userId, 
                'not_attending', 
                reason: reasonController.text.isNotEmpty ? reasonController.text : null
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Submit',
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _openProtocol(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

