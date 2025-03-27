import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.home_work,
                  size: 80,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              AppConstants.appName,
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

