import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Create feedback
  Future<FeedbackModel> createFeedback({
    required String userId,
    required String userName,
    required String message,
  }) async {
    try {
      String feedbackId = _uuid.v4();
      FeedbackModel feedback = FeedbackModel(
        id: feedbackId,
        userId: userId,
        userName: userName,
        message: message,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await _firestore
          .collection(AppConstants.feedbackCollection)
          .doc(feedbackId)
          .set(feedback.toMap());

      return feedback;
    } catch (e) {
      throw Exception('Failed to create feedback: ${e.toString()}');
    }
  }

  // Get feedback for user
  Stream<List<FeedbackModel>> getUserFeedbackStream(String userId) {
    return _firestore
        .collection(AppConstants.feedbackCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  // Get all feedback
  Stream<List<FeedbackModel>> getAllFeedbackStream() {
    return _firestore
        .collection(AppConstants.feedbackCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  // Respond to feedback
  Future<void> respondToFeedback({
    required String feedbackId,
    required String responseMessage,
    required String respondedById,
    required String respondedByName,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.feedbackCollection)
          .doc(feedbackId)
          .update({
        'status': 'responded',
        'responseMessage': responseMessage,
        'respondedById': respondedById,
        'respondedByName': respondedByName,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to respond to feedback: ${e.toString()}');
    }
  }

  // Mark feedback as read
  Future<void> markFeedbackAsRead(String feedbackId) async {
    try {
      await _firestore
          .collection(AppConstants.feedbackCollection)
          .doc(feedbackId)
          .update({
        'status': 'read',
      });
    } catch (e) {
      throw Exception('Failed to mark feedback as read: ${e.toString()}');
    }
  }
}

