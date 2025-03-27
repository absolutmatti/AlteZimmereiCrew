import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/shift_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import 'edit_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  
  const EventDetailScreen({
    Key? key,
    required this.event,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;
    final isCreator = authProvider.user?.id == event.createdById;
    final canEdit = isOwner || isCreator;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Event Details',
        actions: canEdit ? [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEditEvent(context);
              } else if (value == 'delete') {
                _confirmDeleteEvent(context);
              } else if (value == 'publish') {
                _togglePublishStatus(context, true);
              } else if (value == 'unpublish') {
                _togglePublishStatus(context, false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Event'),
                  ],
                ),
              ),
              if (isOwner)
                PopupMenuItem(
                  value: event.isPublished ? 'unpublish' : 'publish',
                  child: Row(
                    children: [
                      Icon(event.isPublished ? Icons.unpublished : Icons.publish),
                      const SizedBox(width: 8),
                      Text(event.isPublished ? 'Unpublish' : 'Publish'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Event', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (event.flyerUrl != null)
              CachedNetworkImage(
                imageUrl: event.flyerUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: AppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(Icons.error, size: 40),
                  ),
                ),
              ),
            
            Padding(
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
                          color: event.date.isAfter(DateTime.now()) 
                              ? AppColors.primary.withOpacity(0.2) 
                              : AppColors.inactive.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.date.isAfter(DateTime.now()) ? 'Upcoming' : 'Past',
                          style: AppTextStyles.caption.copyWith(
                            color: event.date.isAfter(DateTime.now()) 
                                ? AppColors.primary 
                                : AppColors.inactive,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!event.isPublished)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Draft',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Event Name
                  Text(
                    event.name,
                    style: AppTextStyles.headline1,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, dd.MM.yyyy').format(event.date),
                        style: AppTextStyles.subtitle2,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Event Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(event.date),
                        style: AppTextStyles.subtitle2,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Event Description
                  Text(
                    'Description',
                    style: AppTextStyles.headline3,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    event.description,
                    style: AppTextStyles.bodyText1,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Staff Section
                  Text(
                    'Staff',
                    style: AppTextStyles.headline3,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  if (event.staff.isEmpty)
                    Text(
                      'No staff assigned yet',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.inactive,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: event.staff.length,
                      itemBuilder: (context, index) {
                        final entry = event.staff.entries.elementAt(index);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person, color: AppColors.onPrimary),
                          ),
                          title: Text(entry.value, style: AppTextStyles.subtitle2),
                          subtitle: Text(entry.key, style: AppTextStyles.caption),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // DJs Section
                  Text(
                    'DJs',
                    style: AppTextStyles.headline3,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  if (event.djs.isEmpty)
                    Text(
                      'No DJs assigned yet',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.inactive,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: event.djs.length,
                      itemBuilder: (context, index) {
                        final entry = event.djs.entries.elementAt(index);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.secondary,
                            child: Icon(Icons.music_note, color: AppColors.onSecondary),
                          ),
                          title: Text(entry.value, style: AppTextStyles.subtitle2),
                          subtitle: Text(entry.key, style: AppTextStyles.caption),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  if (isOwner)
                    CustomButton(
                      text: 'Manage Shifts',
                      icon: Icons.calendar_month,
                      onPressed: () => _navigateToManageShifts(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToEditEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen(event: event),
      ),
    );
  }
  
  void _navigateToManageShifts(BuildContext context) {
    // Navigate to shifts management screen
    // This would be implemented in a separate screen
  }
  
  Future<void> _confirmDeleteEvent(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Event',
      message: 'Are you sure you want to delete this event? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );
    
    if (confirmed) {
      _deleteEvent(context);
    }
  }
  
  Future<void> _deleteEvent(BuildContext context) async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.deleteEvent(event.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _togglePublishStatus(BuildContext context, bool isPublished) async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.togglePublishStatus(event.id, isPublished);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPublished ? 'Event published' : 'Event unpublished'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update event: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

