import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/event_provider.dart';
import 'providers/meeting_provider.dart';
import 'providers/shift_provider.dart';
import 'providers/time_track_provider.dart';
import 'providers/feedback_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Check if onboarding is completed
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({Key? key, required this.onboardingCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => TimeTrackProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Initialize auth state
          if (!authProvider.isLoading && authProvider.user == null) {
            authProvider.initializeAuth();
          }
          
          return MaterialApp(
            title: 'Alte Zimmerei Crew',
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            home: _getStartScreen(authProvider, onboardingCompleted),
          );
        },
      ),
    );
  }

  Widget _getStartScreen(AuthProvider authProvider, bool onboardingCompleted) {
    if (authProvider.isLoading) {
      return const SplashScreen();
    }
    
    if (!onboardingCompleted) {
      return const OnboardingScreen();
    }
    
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }
    
    return const LoginScreen();
  }
}

