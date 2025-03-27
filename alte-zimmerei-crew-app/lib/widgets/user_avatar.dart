import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    this.imageUrl,
    required this.name,
    this.size = 40.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initials = _getInitials(name);

    Widget avatar;
    if (hasImage) {
      avatar = ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(initials);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildInitialsAvatar(initials);
          },
        ),
      );
    } else {
      avatar = _buildInitialsAvatar(initials);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    
    return '';
  }
}

