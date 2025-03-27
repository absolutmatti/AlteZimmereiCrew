import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../widgets/empty_state.dart';
import 'components/event_card.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeEventProvider();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _initializeEventProvider() {
    // Initialize event provider
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.initializeEvents();
  }
  
  void _navigateToCreateEvent() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.isOwner;
    
    if (!isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only owners can create events'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Events',
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
                // Upcoming Events
                _buildEventsList(eventProvider.upcomingEvents),
                
                // Past Events
                _buildEventsList(eventProvider.events.where(
                  (event) => event.date.isBefore(DateTime.now())
                ).toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEvent,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEventsList(List events) {
    if (events.isEmpty) {
      return EmptyState(
        message: 'No events found',
        icon: Icons.event_busy,
        actionText: 'Create Event',
        onActionPressed: _navigateToCreateEvent,
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh events
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        eventProvider.initializeEvents();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(event: event);
        },
      ),
    );
  }
}

