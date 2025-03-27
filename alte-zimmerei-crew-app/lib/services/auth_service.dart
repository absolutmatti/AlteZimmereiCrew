import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user model stream
  Stream<UserModel> getUserModelStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => UserModel.fromFirestore(doc));
  }

  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword(
      String email, String password, String name, String? phoneNumber) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Create user document in Firestore
      UserModel userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: 'employee', // Default role
        notificationPreferences: [
          AppConstants.newsChannel,
          AppConstants.generalChannel,
          AppConstants.shiftsChannel,
          AppConstants.meetingsChannel,
          AppConstants.eventsChannel,
        ],
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Sign in with Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Update last login
      await _firestore.collection(AppConstants.usersCollection).doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Get user document from Firestore
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile(
      String userId, String name, String? phoneNumber, String? profileImageUrl) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'name': name,
        'phoneNumber': phoneNumber,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });

      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences(
      String userId, List<String> preferences) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'notificationPreferences': preferences,
      });
    } catch (e) {
      throw Exception('Notification preferences update failed: ${e.toString()}');
    }
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(AppConstants.usersCollection).get();
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }
}

