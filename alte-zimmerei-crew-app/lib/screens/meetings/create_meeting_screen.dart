import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meeting_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/date_time_picker.dart';
import '../../widgets/loading_indicator.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({Key? key}) : super(key: key);

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _meetingDate = DateTime.now().add(const Duration(days: 1));
  final List<String> _attendeeIds = [];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_attendeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one attendee'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
    
    try {
      await meetingProvider.createMeeting(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _meetingDate,
        location: _locationController.text,
        createdById: authProvider.user!.id,
        createdByName: authProvider.user!.name,
        attendeeIds: _attendeeIds,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create meeting: ${e.toString()}'),
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
          if (!_attendeeIds.contains(userId)) {
            setState(() {
              _attendeeIds.add(userId);
            });
          }
        },
      ),
    );
  }
  
  void _removeAttendee(String userId) {
    setState(() {
      _attendeeIds.remove(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetingProvider = Provider.of<MeetingProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Create Meeting',
      ),
      body: meetingProvider.isLoading
          ? const LoadingIndicator(message: 'Creating meeting...')
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
                    
                    if (_attendeeIds.isEmpty)
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
                        itemCount: _attendeeIds.length,
                        itemBuilder: (context, index) {
                          final userId = _attendeeIds[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: AppColors.onPrimary),
                            ),
                            title: Text('User ID: $userId', style: AppTextStyles.subtitle2),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _removeAttendee(userId),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Create Button
                    CustomButton(
                      text: 'Create Meeting',
                      onPressed: _createMeeting,
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

