import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/time_track_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/date_time_picker.dart';
import '../../widgets/loading_indicator.dart';

class ManualTimeEntryScreen extends StatefulWidget {
  const ManualTimeEntryScreen({Key? key}) : super(key: key);

  @override
  State<ManualTimeEntryScreen> createState() => _ManualTimeEntryScreenState();
}

class _ManualTimeEntryScreenState extends State<ManualTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _checkInDate = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _checkOutDate = DateTime.now();
  String? _selectedEventId;
  String? _selectedEventName;
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _createManualTimeEntry() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate check-in is before check-out
    if (_checkInDate.isAfter(_checkOutDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in time must be before check-out time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final timeTrackProvider = Provider.of<TimeTrackProvider>(context, listen: false);
    
    try {
      await timeTrackProvider.createManualTimeTrack(
        userId: authProvider.user!.id,
        userName: authProvider.user!.name,
        checkIn: _checkInDate,
        checkOut: _checkOutDate,
        eventId: _selectedEventId,
        eventName: _selectedEventName,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual time entry created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create manual time entry: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _selectEvent() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final events = eventProvider.events;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Select Event',
          style: AppTextStyles.headline3,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: events.isEmpty
              ? const Text('No events found')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event.name, style: AppTextStyles.subtitle2),
                      subtitle: Text(
                        DateFormat('dd.MM.yyyy HH:mm').format(event.date),
                        style: AppTextStyles.caption,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedEventId = event.id;
                          _selectedEventName = event.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedEventId = null;
                _selectedEventName = null;
              });
              Navigator.pop(context);
            },
            child: Text(
              'Clear Selection',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackProvider = Provider.of<TimeTrackProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Manual Time Entry',
      ),
      body: timeTrackProvider.isLoading
          ? const LoadingIndicator(message: 'Creating time entry...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Manual Time Entry',
                      style: AppTextStyles.headline2,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Please note that manual entries require approval.',
                      style: AppTextStyles.bodyText1.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Check-in Date & Time
                    DateTimePicker(
                      label: 'Check-in Date & Time',
                      initialValue: _checkInDate,
                      onChanged: (date) {
                        setState(() {
                          _checkInDate = date;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Check-out Date & Time
                    DateTimePicker(
                      label: 'Check-out Date & Time',
                      initialValue: _checkOutDate,
                      onChanged: (date) {
                        setState(() {
                          _checkOutDate = date;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Event Selection
                    Text(
                      'Select Event (Optional)',
                      style: AppTextStyles.headline3,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    InkWell(
                      onTap: _selectEvent,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedEventName ?? 'No event selected',
                                style: AppTextStyles.bodyText1.copyWith(
                                  color: _selectedEventName != null ? AppColors.onSurface : AppColors.inactive,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppColors.inactive),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notes
                    CustomTextField(
                      controller: _notesController,
                      label: 'Notes (Optional)',
                      hint: 'Enter any additional notes',
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    CustomButton(
                      text: 'Create Time Entry',
                      onPressed: _createManualTimeEntry,
                      isLoading: timeTrackProvider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

