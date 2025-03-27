import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? color;
  final bool isRemovable;
  final VoidCallback? onRemove;

  const TagChip({
    Key? key,
    required this.tag,
    this.onTap,
    this.isSelected = false,
    this.color,
    this.isRemovable = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? (isSelected ? AppColors.primary : AppColors.surface);
    final textColor = isSelected ? AppColors.onPrimary : AppColors.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isRemovable) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

