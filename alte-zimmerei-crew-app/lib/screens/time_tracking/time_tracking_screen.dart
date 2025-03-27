import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/time_track_provider.dart';
import '../../providers/event_provider.dart';
import '../../models/time_track_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'time_track_history_screen.dart';
import 'manual_time_entry_screen.dart';
import 'time_track_approval_screen.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({Key? key}) : super(key: key);

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedEventId;
  String? _selectedEventName;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeProviders();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final timeTrackProvider = Provider.of<TimeTrackProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      timeTrackProvider.initializeUserTimeTracks(authProvider.user!.id);
      
      // Initialize all time tracks if user is owner
      if (authProvider.isOwner) {
        timeTrackProvider.initializeAllTimeTracks();
      }
    }
    
    // Initialize events
    eventProvider.initializeEvents();
  }
  
  Future<void> _checkIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final timeTrackProvider = Provider.of<TimeTrackProvider>(context, listen: false);
    
    try {
      await timeTrackProvider.checkIn(
        userId: authProvider.user!.id,
        userName: authProvider.user!.name,
        eventId: _selectedEventId,
        eventName: _selectedEventName,
        isManualEntry: false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked in successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check in: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _checkOut() async {
    final timeTrackProvider = Provider.of<TimeTrackProvider>(context, listen: false);
    
    try {
      await timeTrackProvider.checkOut();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked out successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check out: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _navigateToManualEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualTimeEntryScreen(),
      ),
    );
  }
  
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TimeTrackHistoryScreen(),
      ),
    );
  }
  
  void _navigateToApproval() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TimeTrackApprovalScreen(),
      ),
    );
  }
  
  void _selectEvent() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final upcomingEvents = eventProvider.upcomingEvents;
    
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
          child: upcomingEvents.isEmpty
              ? const Text('No upcoming events found')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
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
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;
    final activeTimeTrack = timeTrackProvider.activeTimeTrack;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Time Tracking',
        showBackButton: false,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.approval),
              onPressed: _navigateToApproval,
              tooltip: 'Approve Time Entries',
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
            tooltip: 'View History',
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.inactive,
            tabs: const [
              Tab(text: 'Check In/Out'),
              Tab(text: 'Recent Entries'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Check In/Out Tab
                _buildCheckInOutTab(activeTimeTrack),
                
                // Recent Entries Tab
                _buildRecentEntriesTab(timeTrackProvider.userTimeTracks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToManualEntry,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        tooltip: 'Manual Entry',
      ),
    );
  }
  
  Widget _buildCheckInOutTab(TimeTrackModel? activeTimeTrack) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Card
          Card(
            color: AppColors.surface,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: activeTimeTrack != null ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activeTimeTrack != null ? 'Checked In' : 'Checked Out',
                        style: AppTextStyles.subtitle1.copyWith(
                          color: activeTimeTrack != null ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  if (activeTimeTrack != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Since: ${DateFormat('dd.MM.yyyy HH:mm').format(activeTimeTrack.checkIn)}',
                      style: AppTextStyles.bodyText2,
                    ),
                    if (activeTimeTrack.eventName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Event: ${activeTimeTrack.eventName}',
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Event Selection
          if (activeTimeTrack == null) ...[
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
            
            const SizedBox(height: 32),
          ],
          
          // Check In/Out Button
          CustomButton(
            text: activeTimeTrack != null ? 'Check Out' : 'Check In',
            icon: activeTimeTrack != null ? Icons.logout : Icons.login,
            onPressed: activeTimeTrack != null ? _checkOut : _checkIn,
          ),
          
          const SizedBox(height: 16),
          
          // Manual Entry Button
          CustomButton(
            text: 'Manual Time Entry',
            icon: Icons.edit_calendar,
            type: ButtonType.outline,
            onPressed: _navigateToManualEntry,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentEntriesTab(List<TimeTrackModel> timeTracks) {
    if (timeTracks.isEmpty) {
      return const EmptyState(
        message: 'No time entries found',
        icon: Icons.history,
      );
    }
    
    // Show only the 10 most recent entries
    final recentTracks = timeTracks.take(10).toList();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Time Entries',
                style: AppTextStyles.headline3,
              ),
              TextButton(
                onPressed: _navigateToHistory,
                child: Text(
                  'View All',
                  style: AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentTracks.length,
            itemBuilder: (context, index) {
              final track = recentTracks[index];
              return _buildTimeTrackItem(track);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeTrackItem(TimeTrackModel track) {
    final bool isCompleted = track.checkOut != null;
    final String duration = isCompleted ? track.getFormattedDuration() : 'In progress';
    
    Color statusColor;
    String statusText;
    
    switch (track.status) {
      case 'approved':
        statusColor = AppColors.success;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Rejected';
        break;
      case 'pending':
      default:
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd.MM.yyyy').format(track.checkIn),
                  style: AppTextStyles.subtitle1,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.inactive),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(track.checkIn)} - ${isCompleted ? DateFormat('HH:mm').format(track.checkOut!) : 'Now'}',
                  style: AppTextStyles.bodyText2,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timelapse, size: 16, color: AppColors.inactive),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: AppTextStyles.bodyText2,
                ),
              ],
            ),
            if (track.eventName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: AppColors.inactive),
                  const SizedBox(width: 4),
                  Text(
                    track.eventName!,
                    style: AppTextStyles.bodyText2,
                  ),
                ],
              ),
            ],
            if (track.notes != null && track.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${track.notes}',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

