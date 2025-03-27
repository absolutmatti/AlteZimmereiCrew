import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/event_model.dart';
import '../../../widgets/custom_card.dart';
import '../event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  
  const EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = event.date.isAfter(DateTime.now());
    
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(event: event),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          if (event.flyerUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: event.flyerUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: AppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(Icons.error, size: 40),
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
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
                        DateFormat('dd.MM.yyyy HH:mm').format(event.date),
                        style: AppTextStyles.caption.copyWith(
                          color: isUpcoming ? AppColors.primary : AppColors.inactive,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (!event.isPublished)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Draft',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Event Name
                Text(
                  event.name,
                  style: AppTextStyles.headline3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Event Description
                Text(
                  event.description,
                  style: AppTextStyles.bodyText2,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Staff Count and DJs
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.inactive,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.staff.length} Staff',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.music_note,
                      size: 16,
                      color: AppColors.inactive,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.djs.length} DJs',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

