import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../feed/feed_screen.dart';
import '../shifts/shifts_screen.dart';
import '../events/events_screen.dart';
import '../time_tracking/time_tracking_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../onboarding/feature_tour.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
    _checkFeatureTour();
  }

  void _initializeProviders() {
    // Initialize providers that need to be loaded when the app starts
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      // Initialize other providers here
    }
  }

  Future<void> _checkFeatureTour() async {
    if (_isFirstLoad) {
      _isFirstLoad = false;
      
      // Check if feature tour is completed
      bool isCompleted = await FeatureTour.isCompleted();
      if (!isCompleted) {
        // Wait for the widget to be fully built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FeatureTour.showFeedTour(context);
        });
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;
    
    // Define screens based on user role
    _screens = [
      const FeedScreen(),
      const ShiftsScreen(),
      const EventsScreen(),
      const TimeTrackingScreen(),
      const ProfileScreen(),
    ];
    
    // Add admin screen for owners
    if (isOwner) {
      _screens.add(const AdminScreen());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        isOwner: isOwner,
      ),
    );
  }
}

