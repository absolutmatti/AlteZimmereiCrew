import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/date_time_picker.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/loading_indicator.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  File? _flyerImage;
  final Map<String, String> _staff = {};
  final Map<String, String> _djs = {};
  bool _isPublished = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    try {
      await eventProvider.createEvent(
        name: _nameController.text,
        date: _eventDate,
        description: _descriptionController.text,
        flyerFile: _flyerImage,
        staff: _staff,
        djs: _djs,
        isPublished: _isPublished,
        createdById: authProvider.user!.id,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _addStaffMember() {
    showDialog(
      context: context,
      builder: (context) => _AddPersonDialog(
        title: 'Add Staff Member',
        onAdd: (role, name) {
          setState(() {
            _staff[role] = name;
          });
        },
      ),
    );
  }
  
  void _addDj() {
    showDialog(
      context: context,
      builder: (context) => _AddPersonDialog(
        title: 'Add DJ',
        roleLabel: 'Time Slot',
        onAdd: (slot, name) {
          setState(() {
            _djs[slot] = name;
          });
        },
      ),
    );
  }
  
  void _removeStaffMember(String role) {
    setState(() {
      _staff.remove(role);
    });
  }
  
  void _removeDj(String slot) {
    setState(() {
      _djs.remove(slot);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Create Event',
      ),
      body: eventProvider.isLoading
          ? const LoadingIndicator(message: 'Creating event...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Flyer
                    ImagePickerWidget(
                      label: 'Event Flyer',
                      image: _flyerImage,
                      onImagePicked: (file) {
                        setState(() {
                          _flyerImage = file;
                        });
                      },
                      height: 200,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Event Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Event Name',
                      hint: 'Enter event name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter event name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Event Date
                    DateTimePicker(
                      label: 'Event Date & Time',
                      initialValue: _eventDate,
                      onChanged: (date) {
                        setState(() {
                          _eventDate = date;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Event Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter event description',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter event description';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Staff Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Staff',
                          style: AppTextStyles.headline3,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: _addStaffMember,
                        ),
                      ],
                    ),
                    
                    if (_staff.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No staff members added yet',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.inactive,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _staff.length,
                        itemBuilder: (context, index) {
                          final entry = _staff.entries.elementAt(index);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: AppColors.onPrimary),
                            ),
                            title: Text(entry.value, style: AppTextStyles.subtitle2),
                            subtitle: Text(entry.key, style: AppTextStyles.caption),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _removeStaffMember(entry.key),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // DJs Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DJs',
                          style: AppTextStyles.headline3,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: _addDj,
                        ),
                      ],
                    ),
                    
                    if (_djs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No DJs added yet',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.inactive,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _djs.length,
                        itemBuilder: (context, index) {
                          final entry = _djs.entries.elementAt(index);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: Icon(Icons.music_note, color: AppColors.onSecondary),
                            ),
                            title: Text(entry.value, style: AppTextStyles.subtitle2),
                            subtitle: Text(entry.key, style: AppTextStyles.caption),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _removeDj(entry.key),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Publish Switch
                    SwitchListTile(
                      title: Text(
                        'Publish Event',
                        style: AppTextStyles.subtitle1,
                      ),
                      subtitle: Text(
                        'Make this event visible to all users',
                        style: AppTextStyles.caption,
                      ),
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() {
                          _isPublished = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Create Button
                    CustomButton(
                      text: 'Create Event',
                      onPressed: _createEvent,
                      isLoading: eventProvider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AddPersonDialog extends StatefulWidget {
  final String title;
  final String roleLabel;
  final Function(String, String) onAdd;
  
  const _AddPersonDialog({
    Key? key,
    required this.title,
    this.roleLabel = 'Role',
    required this.onAdd,
  }) : super(key: key);

  @override
  State<_AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<_AddPersonDialog> {
  final _roleController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _roleController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_roleController.text, _nameController.text);
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.title,
        style: AppTextStyles.headline3,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _roleController,
              label: widget.roleLabel,
              hint: 'Enter ${widget.roleLabel.toLowerCase()}',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ${widget.roleLabel.toLowerCase()}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
          ],
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

