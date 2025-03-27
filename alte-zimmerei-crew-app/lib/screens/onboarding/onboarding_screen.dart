import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Alte Zimmerei Crew',
      'description': 'Your all-in-one app for managing shifts, events, and communication with your team.',
      'image': 'assets/images/onboarding_1.png',
      'icon': Icons.home_work,
    },
    {
      'title': 'Stay Connected',
      'description': 'Get real-time updates about shifts, events, and important announcements.',
      'image': 'assets/images/onboarding_2.png',
      'icon': Icons.notifications_active,
    },
    {
      'title': 'Track Your Time',
      'description': 'Easily track your working hours and manage your schedule.',
      'image': 'assets/images/onboarding_3.png',
      'icon': Icons.timer,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    // Save that onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Navigate to login screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  return _buildPage(
                    title: _pages[index]['title'],
                    description: _pages[index]['description'],
                    image: _pages[index]['image'],
                    icon: _pages[index]['icon'],
                  );
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _numPages,
                (index) => _buildPageIndicator(index == _currentPage),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: CustomButton(
                text: _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String image,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or icon placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 100,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            style: AppTextStyles.headline2,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            style: AppTextStyles.bodyText1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.inactive,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

