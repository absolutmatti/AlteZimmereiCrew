import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year', 'All Time'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Statistics',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.inactive,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Shifts'),
            Tab(text: 'Time'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Period:',
                  style: AppTextStyles.subtitle2,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    underline: Container(
                      height: 1,
                      color: AppColors.divider,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                      }
                    },
                    items: _periods.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Stats summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Events',
                    value: '12',
                    icon: Icons.event,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Shifts',
                    value: '48',
                    icon: Icons.work,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Hours',
                    value: '256',
                    icon: Icons.timer,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Events Tab
                _buildEventsTab(),
                
                // Shifts Tab
                _buildShiftsTab(),
                
                // Time Tab
                _buildTimeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inactive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headline3,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events by Type',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: Text(
                  'Event Type Chart',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Attendance',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: Text(
                  'Attendance Chart',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Top Events',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Event ${index + 1}'),
                  subtitle: Text('${20 - index * 2} attendees'),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shifts by Type',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: Text(
                  'Shift Type Chart',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Shift Changes',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: Text(
                  'Shift Changes Chart',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Top Crew Members',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Crew Member ${index + 1}'),
                  subtitle: Text('${15 - index} shifts'),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hours by Day',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: Text(
                  'Hours by Day Chart',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Hours by Event',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: Text(
                  'Hours by Event Chart',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Top Time Trackers',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Crew Member ${index + 1}'),
                  subtitle: Text('${50 - index * 5} hours'),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

