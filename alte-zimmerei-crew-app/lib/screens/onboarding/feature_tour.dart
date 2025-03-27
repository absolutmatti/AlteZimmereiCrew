import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class FeatureTour {
  static const String _prefKey = 'feature_tour_completed';
  
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }
  
  static Future<void> markAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }
  
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, false);
  }
  
  static void showFeedTour(BuildContext context) {
    _showFeatureHighlight(
      context: context,
      title: 'Feed',
      description: 'Stay updated with the latest news and announcements.',
      position: _HighlightPosition.bottomLeft,
      onNext: () => showShiftsTour(context),
    );
  }
  
  static void showShiftsTour(BuildContext context) {
    _showFeatureHighlight(
      context: context,
      title: 'Shifts',
      description: 'View and manage your upcoming shifts.',
      position: _HighlightPosition.bottom,
      onNext: () => showEventsTour(context),
    );
  }
  
  static void showEventsTour(BuildContext context) {
    _showFeatureHighlight(
      context: context,
      title: 'Events',
      description: 'Check out upcoming events at Alte Zimmerei.',
      position: _HighlightPosition.bottom,
      onNext: () => showTimeTour(context),
    );
  }
  
  static void showTimeTour(BuildContext context) {
    _showFeatureHighlight(
      context: context,
      title: 'Time Tracking',
      description: 'Track your working hours and view your history.',
      position: _HighlightPosition.bottom,
      onNext: () => showProfileTour(context),
    );
  }
  
  static void showProfileTour(BuildContext context) {
    _showFeatureHighlight(
      context: context,
      title: 'Profile',
      description: 'Manage your profile and app settings.',
      position: _HighlightPosition.bottomRight,
      onNext: () async {
        await markAsCompleted();
      },
    );
  }
  
  static void _showFeatureHighlight({
    required BuildContext context,
    required String title,
    required String description,
    required _HighlightPosition position,
    required VoidCallback onNext,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => _FeatureHighlight(
        title: title,
        description: description,
        position: position,
        onNext: () {
          overlay.remove();
          onNext();
        },
        onSkip: () async {
          overlay.remove();
          await markAsCompleted();
        },
      ),
    );
    
    Overlay.of(context).insert(overlay);
  }
}

enum _HighlightPosition {
  topLeft,
  top,
  topRight,
  bottomLeft,
  bottom,
  bottomRight,
}

class _FeatureHighlight extends StatelessWidget {
  final String title;
  final String description;
  final _HighlightPosition position;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _FeatureHighlight({
    Key? key,
    required this.title,
    required this.description,
    required this.position,
    required this.onNext,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Stack(
        children: [
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip Tour',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Feature highlight
          Positioned(
            bottom: _getBottomPosition(),
            left: _getLeftPosition(),
            right: _getRightPosition(),
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTextStyles.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onNext,
                      child: Text(
                        'Next',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Highlight arrow
          _buildArrow(),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    switch (position) {
      case _HighlightPosition.bottomLeft:
        return Positioned(
          bottom: 120,
          left: 30,
          child: Icon(
            Icons.arrow_downward,
            color: AppColors.primary,
            size: 40,
          ),
        );
      case _HighlightPosition.bottom:
        return Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: Icon(
              Icons.arrow_downward,
              color: AppColors.primary,
              size: 40,
            ),
          ),
        );
      case _HighlightPosition.bottomRight:
        return Positioned(
          bottom: 120,
          right: 30,
          child: Icon(
            Icons.arrow_downward,
            color: AppColors.primary,
            size: 40,
          ),
        );
      case _HighlightPosition.topLeft:
        return Positioned(
          top: 120,
          left: 30,
          child: Icon(
            Icons.arrow_upward,
            color: AppColors.primary,
            size: 40,
          ),
        );
      case _HighlightPosition.top:
        return Positioned(
          top: 120,
          left: 0,
          right: 0,
          child: Center(
            child: Icon(
              Icons.arrow_upward,
              color: AppColors.primary,
              size: 40,
            ),
          ),
        );
      case _HighlightPosition.topRight:
        return Positioned(
          top: 120,
          right: 30,
          child: Icon(
            Icons.arrow_upward,
            color: AppColors.primary,
            size: 40,
          ),
        );
    }
  }

  double? _getBottomPosition() {
    switch (position) {
      case _HighlightPosition.bottomLeft:
      case _HighlightPosition.bottom:
      case _HighlightPosition.bottomRight:
        return 150;
      default:
        return null;
    }
  }

  double? _getLeftPosition() {
    switch (position) {
      case _HighlightPosition.topLeft:
      case _HighlightPosition.bottomLeft:
        return 20;
      case _HighlightPosition.top:
      case _HighlightPosition.bottom:
        return 50;
      default:
        return null;
    }
  }

  double? _getRightPosition() {
    switch (position) {
      case _HighlightPosition.topRight:
      case _HighlightPosition.bottomRight:
        return 20;
      case _HighlightPosition.top:
      case _HighlightPosition.bottom:
        return 50;
      default:
        return null;
    }
  }
}

