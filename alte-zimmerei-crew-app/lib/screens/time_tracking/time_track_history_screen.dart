import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/time_track_provider.dart';
import '../../models/time_track_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class TimeTrackHistoryScreen extends StatefulWidget {
  const TimeTrackHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TimeTrackHistoryScreen> createState() => _TimeTrackHistoryScreenState();
}

class _TimeTrackHistoryScreenState extends State<TimeTrackHistoryScreen> {
  DateTime _selectedMonth = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final timeTrackProvider = Provider.of<TimeTrackProvider>(context);
    final timeTracks = timeTrackProvider.userTimeTracks;
    
    // Filter time tracks for the selected month
    final filteredTracks = timeTracks.where((track) {
      return track.checkIn.year == _selectedMonth.year && 
             track.checkIn.month == _selectedMonth.month;
    }).toList();
    
    // Calculate total hours for the month
    Duration totalDuration = Duration.zero;
    for (var track in filteredTracks) {
      if (track.checkOut != null) {
        totalDuration += track.getDuration();
      }
    }
    
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Time History',
      ),
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                        1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: AppTextStyles.headline3,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final now = DateTime.now();
                    final nextMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                      1,
                    );
                    
                    // Don't allow selecting future months
                    if (nextMonth.year < now.year || 
                        (nextMonth.year == now.year && nextMonth.month <= now.month)) {
                      setState(() {
                        _selectedMonth = nextMonth;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Total Hours Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Hours',
                        style: AppTextStyles.subtitle2,
                      ),
                      Text(
                        '$hours:${minutes.toString().padLeft(2, '0')}',
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Time Entries List
          Expanded(
            child: filteredTracks.isEmpty
                ? const EmptyState(
                    message: 'No time entries for this month',
                    icon: Icons.event_busy,
                  )
                : ListView.builder(
                    itemCount: filteredTracks.length,
                    itemBuilder: (context, index) {
                      return _buildTimeTrackItem(filteredTracks[index]);
                    },
                  ),
          ),
        ],
      ),
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
                  DateFormat('EEEE, dd.MM.yyyy').format(track.checkIn),
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
                const Spacer(),
                const Icon(Icons.timelapse, size: 16, color: AppColors.inactive),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: AppTextStyles.bodyText2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
            if (track.isManualEntry) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.edit, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Manual Entry',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                    ),
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

