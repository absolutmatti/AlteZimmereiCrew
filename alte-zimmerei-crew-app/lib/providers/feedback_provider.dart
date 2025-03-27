import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();
  List<FeedbackModel> _userFeedback = [];
  List<FeedbackModel> _allFeedback = [];
  bool _isLoading = false;
  String? _error;

  List<FeedbackModel> get userFeedback => _userFeedback;
  List<FeedbackModel> get allFeedback => _allFeedback;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize feedback for a user
  void initializeUserFeedback(String userId) {
    _feedbackService.getUserFeedbackStream(userId).listen((feedback) {
      _userFeedback = feedback;
      notifyListeners();
    });
  }

  // Initialize all feedback (for admin)
  void initializeAllFeedback() {
    _feedbackService.getAllFeedbackStream().listen((feedback) {
      _allFeedback = feedback;
      notifyListeners();
    });
  }

  // Create feedback
  Future<void> createFeedback({
    required String userId,
    required String userName,
    required String message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _feedbackService.createFeedback(
        userId: userId,
        userName: userName,
        message: message,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Respond to feedback
  Future<void> respondToFeedback({
    required String feedbackId,
    required String responseMessage,
    required String respondedById,
    required String respondedByName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _feedbackService.respondToFeedback(
        feedbackId: feedbackId,
        responseMessage: responseMessage,
        respondedById: respondedById,
        respondedByName: respondedByName,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark feedback as read
  Future<void> markFeedbackAsRead(String feedbackId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _feedbackService.markFeedbackAsRead(feedbackId);
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

