import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          title,
          style: AppTextStyles.headline3,
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyText1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(
              confirmText,
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}

