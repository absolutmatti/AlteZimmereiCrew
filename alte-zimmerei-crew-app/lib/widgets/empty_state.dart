import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'custom_button.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double iconSize;
  final double spacing;

  const EmptyState({
    Key? key,
    required this.message,
    required this.icon,
    this.actionText,
    this.onActionPressed,
    this.iconSize = 80.0,
    this.spacing = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppColors.inactive,
            ),
            SizedBox(height: spacing),
            Text(
              message,
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.inactive,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: spacing),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed!,
                isFullWidth: false,
                type: ButtonType.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

