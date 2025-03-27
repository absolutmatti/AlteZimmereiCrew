import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime initialValue;
  final Function(DateTime) onChanged;
  final bool showTime;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateTimePicker({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.showTime = true,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDateTimePicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  _formatDateTime(initialValue),
                  style: AppTextStyles.bodyText1,
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: AppColors.inactive),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    if (showTime) {
      return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    }
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialValue,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (showTime) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialValue),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onPrimary,
                  surface: AppColors.surface,
                  onSurface: AppColors.onSurface,
                ),
                dialogBackgroundColor: AppColors.background,
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          final DateTime combinedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          onChanged(combinedDateTime);
        }
      } else {
        onChanged(pickedDate);
      }
    }
  }
}

