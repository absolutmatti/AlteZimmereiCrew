import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

enum ButtonType {
  primary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? color;
  final double height;
  final double borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.color,
    this.height = 48.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button style based on type
    ButtonStyle buttonStyle;
    Color textColor;
    
    switch (type) {
      case ButtonType.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        textColor = AppColors.onPrimary;
        break;
      case ButtonType.outline:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: color ?? AppColors.primary,
          side: BorderSide(color: color ?? AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        textColor = color ?? AppColors.primary;
        break;
      case ButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: color ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
        textColor = color ?? AppColors.primary;
        break;
    }

    // Create button content
    Widget buttonContent;
    if (isLoading) {
      buttonContent = SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else if (icon != null) {
      buttonContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.button.copyWith(color: textColor),
          ),
        ],
      );
    } else {
      buttonContent = Text(
        text,
        style: AppTextStyles.button.copyWith(color: textColor),
      );
    }

    // Create the button based on type
    Widget button;
    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
    }

    // Wrap in a container with fixed height if needed
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: button,
    );
  }
}

