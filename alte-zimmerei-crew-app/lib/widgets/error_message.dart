import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'custom_button.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData icon;
  final double iconSize;
  final double spacing;

  const ErrorMessage({
    Key? key,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.icon = Icons.error_outline,
    this.iconSize = 60.0,
    this.spacing = 16.0,
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
              color: AppColors.error,
            ),
            SizedBox(height: spacing),
            Text(
              message,
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: spacing),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed!,
                isFullWidth: false,
                color: AppColors.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

