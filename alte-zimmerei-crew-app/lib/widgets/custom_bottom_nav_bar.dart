import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isOwner;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isOwner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.inactive,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Shifts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Time',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          if (isOwner)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}

