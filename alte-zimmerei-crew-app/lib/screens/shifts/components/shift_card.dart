import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/shift_model.dart';
import '../../../widgets/custom_card.dart';
import '../shift_detail_screen.dart';

class ShiftCard extends StatelessWidget {
  final ShiftModel shift;
  
  const ShiftCard({
    Key? key,
    required this.shift,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = shift.date.isAfter(DateTime.now());
    
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShiftDetailScreen(shift: shift),
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
                  DateFormat('dd.MM.yyyy HH:mm').format(shift.date),
                  style: AppTextStyles.caption.copyWith(
                    color: isUpcoming ? AppColors.primary : AppColors.inactive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(shift),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Event Name
          Text(
            shift.eventName,
            style: AppTextStyles.headline3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Shift Type
          Row(
            children: [
              const Icon(
                Icons.work,
                size: 16,
                color: AppColors.inactive,
              ),
              const SizedBox(width: 4),
              Text(
                shift.shiftType,
                style: AppTextStyles.subtitle2,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Assigned To
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 16,
                color: AppColors.inactive,
              ),
              const SizedBox(width: 4),
              Text(
                'Assigned to: ${shift.assignedToName}',
                style: AppTextStyles.bodyText2,
              ),
            ],
          ),
          
          // Original Assigned To (if changed)
          if (shift.originalAssignedToName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.swap_horiz,
                  size: 16,
                  color: AppColors.inactive,
                ),
                const SizedBox(width: 4),
                Text(
                  'Originally assigned to: ${shift.originalAssignedToName}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(ShiftModel shift) {
    Color color;
    String text;
    
    switch (shift.status) {
      case 'requested_change':
        color = AppColors.warning;
        text = 'Change Requested';
        break;
      case 'change_approved':
        color = AppColors.success;
        text = 'Change Approved';
        break;
      case 'assigned':
      default:
        color = AppColors.info;
        text = 'Assigned';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

