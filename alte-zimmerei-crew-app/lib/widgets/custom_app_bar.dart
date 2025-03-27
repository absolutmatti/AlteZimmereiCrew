import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.headline3.copyWith(
          color: foregroundColor ?? AppColors.onSurface,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.onSurface,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize.height ?? 0.0));
}

