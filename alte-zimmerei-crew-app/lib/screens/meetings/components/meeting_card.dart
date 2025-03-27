import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/meeting_model.dart';
import '../../../widgets/custom_card.dart';
import '../meeting_detail_screen.dart';

class MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  
  const MeetingCard({
    Key? key,
    required this.meeting,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = meeting.date.isAfter(DateTime.now());
    
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeetingDetailScreen(meeting: meeting),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming ? AppColors.primary.withOpacity(0.2) : AppColors.inactive.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(meeting.date),
                  style: AppTextStyles.caption.copyWith(
                    color: isUpcoming ? AppColors.primary : AppColors.inactive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              _buildAttendanceStatus(meeting),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Meeting Title
          Text(
            meeting.title,
            style: AppTextStyles.headline3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Meeting Description
          Text(
            meeting.description,
            style: AppTextStyles.bodyText2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Location and Attendees
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.inactive,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  meeting.location,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.people,
                size: 16,
                color: AppColors.inactive,
              ),
              const SizedBox(width: 4),
              Text(
                '${meeting.attendees.length} Attendees',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttendanceStatus(MeetingModel meeting) {
    // This would typically check the current user's attendance status
    // For now, we'll just show a generic status
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Pending',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.info,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

