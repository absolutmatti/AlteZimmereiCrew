import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shift_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../widgets/empty_state.dart';
import 'components/shift_card.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({Key? key}) : super(key: key);

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeShiftProvider();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _initializeShiftProvider() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    
    // Initialize user shifts
    if (authProvider.user != null) {
      shiftProvider.initializeUserShifts(authProvider.user!.id);
    }
    
    // Initialize all shifts if user is owner
    if (authProvider.isOwner) {
      shiftProvider.initializeAllShifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Shifts',
        showBackButton: false,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.inactive,
            tabs: [
              const Tab(text: 'My Shifts'),
              if (isOwner) const Tab(text: 'All Shifts') else const Tab(text: 'Available'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // My Shifts
                _buildShiftsList(shiftProvider.userShifts, 'my'),
                
                // All Shifts or Available Shifts
                isOwner
                    ? _buildShiftsList(shiftProvider.allShifts, 'all')
                    : _buildAvailableShiftsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShiftsList(List shifts, String type) {
    if (shifts.isEmpty) {
      return EmptyState(
        message: type == 'my' 
            ? 'You have no shifts assigned' 
            : 'No shifts found',
        icon: Icons.event_busy,
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh shifts
        _initializeShiftProvider();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];
          return ShiftCard(shift: shift);
        },
      ),
    );
  }
  
  Widget _buildAvailableShiftsList() {
    // This would show shifts that are available for taking
    // For now, we'll just show an empty state
    return EmptyState(
      message: 'No shifts available for taking',
      icon: Icons.event_busy,
    );
  }
}

