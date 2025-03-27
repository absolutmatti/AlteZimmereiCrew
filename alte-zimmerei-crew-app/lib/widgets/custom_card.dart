import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? borderColor;

  const CustomCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.borderRadius = 12.0,
    this.elevation = 2.0,
    this.onTap,
    this.hasBorder = false,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: child,
    );

    final card = Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: color ?? AppColors.cardBackground,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: hasBorder
            ? BorderSide(
                color: borderColor ?? AppColors.divider,
                width: 1.0,
              )
            : BorderSide.none,
      ),
      child: cardContent,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}

