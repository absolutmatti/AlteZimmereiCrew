import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firebase: ${e.toString()}');
      // Show error dialog or notification to the user
      rethrow;
    }
  }
}

