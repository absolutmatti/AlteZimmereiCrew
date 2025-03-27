import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/meeting_model.dart';
import '../../providers/meeting_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/date_time_picker.dart';
import '../../widgets/loading_indicator.dart';

class EditMeetingScreen extends StatefulWidget {
  final MeetingModel meeting;
  
  const EditMeetingScreen({
    Key? key,
    required this.meeting,
  }) : super(key: key);

  @override
  State<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends State<EditMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _meetingDate;
  late Map<String, AttendanceStatus> _attendees;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.meeting.title);
    _descriptionController = TextEditingController(text: widget.meeting.description);
    _locationController = TextEditingController(text: widget.meeting.location);
    _meetingDate = widget.meeting.date;
    _attendees = Map.from(widget.meeting.attendees);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _updateMeeting() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_attendees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one attendee'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
    
    try {
      final updatedMeeting = widget.meeting.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _meetingDate,
        location: _locationController.text,
        attendees: _attendees,
      );
      
      await meetingProvider.updateMeeting(updatedMeeting);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update meeting: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _addAttendee() {
    showDialog(
      context: context,
      builder: (context) => _AddAttendeeDialog(
        onAdd: (userId) {
          if (!_attendees.containsKey(userId)) {
            setState(() {
              _attendees[userId] = AttendanceStatus(
                status: 'pending',
                updatedAt: DateTime.now(),
              );
            });
          }
        },
      ),
    );
  }
  
  void _removeAttendee(String userId) {
    setState(() {
      _attendees.remove(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetingProvider = Provider.of<MeetingProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Edit Meeting',
      ),
      body: meetingProvider.isLoading
          ? const LoadingIndicator(message: 'Updating meeting...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meeting Title
                    CustomTextField(
                      controller: _titleController,
                      label: 'Meeting Title',
                      hint: 'Enter meeting title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter meeting title';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Meeting Date
                    DateTimePicker(
                      label: 'Meeting Date & Time',
                      initialValue: _meetingDate,
                      onChanged: (date) {
                        setState(() {
                          _meetingDate = date;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Meeting Location
                    CustomTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'Enter meeting location',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter meeting location';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Meeting Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter meeting description',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter meeting description';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Attendees Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attendees',
                          style: AppTextStyles.headline3,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: _addAttendee,
                        ),
                      ],
                    ),
                    
                    if (_attendees.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No attendees added yet',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.inactive,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _attendees.length,
                        itemBuilder: (context, index) {
                          final entry = _attendees.entries.elementAt(index);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: AppColors.onPrimary),
                            ),
                            title: Text('User ID: ${entry.key}', style: AppTextStyles.subtitle2),
                            subtitle: Text(
                              'Status: ${entry.value.status}',
                              style: AppTextStyles.caption,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _removeAttendee(entry.key),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Update Button
                    CustomButton(
                      text: 'Update Meeting',
                      onPressed: _updateMeeting,
                      isLoading: meetingProvider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AddAttendeeDialog extends StatefulWidget {
  final Function(String) onAdd;
  
  const _AddAttendeeDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<_AddAttendeeDialog> createState() => _AddAttendeeDialogState();
}

class _AddAttendeeDialogState extends State<_AddAttendeeDialog> {
  final _userIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_userIdController.text);
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        'Add Attendee',
        style: AppTextStyles.headline3,
      ),
      content: Form(
        key: _formKey,
        child: CustomTextField(
          controller: _userIdController,
          label: 'User ID',
          hint: 'Enter user ID',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter user ID';
            }
            return null;
          },
        ),
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: Text(
            'Add',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }
}

