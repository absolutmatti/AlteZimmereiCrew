import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isOwner => _user?.isOwner() ?? false;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      User? firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        // Get user data from Firestore
        _authService.getUserModelStream(firebaseUser.uid).listen((userModel) {
          _user = userModel;
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<void> register(String email, String password, String name, String? phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.registerWithEmailAndPassword(
          email, password, name, phoneNumber);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile(String name, String? phoneNumber, String? profileImageUrl) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.updateUserProfile(
          _user!.id, name, phoneNumber, profileImageUrl);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences(List<String> preferences) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateNotificationPreferences(_user!.id, preferences);
      // User model will be updated via the stream
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

