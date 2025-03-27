import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meeting_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../widgets/empty_state.dart';
import 'components/meeting_card.dart';
import 'create_meeting_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeMeetingProvider();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _initializeMeetingProvider() {
    // Initialize meeting provider
    final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
    meetingProvider.initializeMeetings();
  }
  
  void _navigateToCreateMeeting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateMeetingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meetingProvider = Provider.of<MeetingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Meetings',
        showBackButton: false,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.inactive,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Meetings
                _buildMeetingsList(meetingProvider.upcomingMeetings),
                
                // Past Meetings
                _buildMeetingsList(meetingProvider.meetings.where(
                  (meeting) => meeting.date.isBefore(DateTime.now())
                ).toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMeeting,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildMeetingsList(List meetings) {
    if (meetings.isEmpty) {
      return EmptyState(
        message: 'No meetings found',
        icon: Icons.event_busy,
        actionText: 'Create Meeting',
        onActionPressed: _navigateToCreateMeeting,
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh meetings
        final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
        meetingProvider.initializeMeetings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return MeetingCard(meeting: meeting);
        },
      ),
    );
  }
}

