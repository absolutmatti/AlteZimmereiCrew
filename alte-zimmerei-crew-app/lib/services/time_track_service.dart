import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/time_track_model.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class TimeTrackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Check in
  Future<TimeTrackModel> checkIn({
    required String userId,
    required String userName,
    String? eventId,
    String? eventName,
    required bool isManualEntry,
  }) async {
    try {
      String trackId = _uuid.v4();
      TimeTrackModel track = TimeTrackModel(
        id: trackId,
        userId: userId,
        userName: userName,
        checkIn: DateTime.now(),
        eventId: eventId,
        eventName: eventName,
        isManualEntry: isManualEntry,
        status: isManualEntry ? 'pending' : 'approved',
      );

      await _firestore
          .collection(AppConstants.timeTracksCollection)
          .doc(trackId)
          .set(track.toMap());

      return track;
    } catch (e) {
      throw Exception('Failed to check in: ${e.toString()}');
    }
  }

  // Check out
  Future<void> checkOut(String trackId) async {
    try {
      await _firestore
          .collection(AppConstants.timeTracksCollection)
          .doc(trackId)
          .update({
        'checkOut': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to check out: ${e.toString()}');
    }
  }

  // Get active time track for user
  Future<TimeTrackModel?> getActiveTimeTrack(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.timeTracksCollection)
          .where('userId', isEqualTo: userId)
          .where('checkOut', isNull: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      return TimeTrackModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get active time track: ${e.toString()}');
    }
  }

  // Get time tracks for user
  Stream<List<TimeTrackModel>> getUserTimeTracksStream(String userId) {
    return _firestore
        .collection(AppConstants.timeTracksCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('checkIn', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimeTrackModel.fromFirestore(doc))
            .toList());
  }

  // Get all time tracks
  Stream<List<TimeTrackModel>> getAllTimeTracksStream() {
    return _firestore
        .collection(AppConstants.timeTracksCollection)
        .orderBy('checkIn', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimeTrackModel.fromFirestore(doc))
            .toList());
  }

  // Get pending time tracks
  Stream<List<TimeTrackModel>> getPendingTimeTracksStream() {
    return _firestore
        .collection(AppConstants.timeTracksCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('checkIn', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimeTrackModel.fromFirestore(doc))
            .toList());
  }

  // Approve time track
  Future<void> approveTimeTrack(
      String trackId, String approvedById, String approvedByName) async {
    try {
      await _firestore
          .collection(AppConstants.timeTracksCollection)
          .doc(trackId)
          .update({
        'status': 'approved',
        'approvedById': approvedById,
        'approvedByName': approvedByName,
        'approvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to approve time track: ${e.toString()}');
    }
  }

  // Reject time track
  Future<void> rejectTimeTrack(
      String trackId, String approvedById, String approvedByName, String notes) async {
    try {
      await _firestore
          .collection(AppConstants.timeTracksCollection)
          .doc(trackId)
          .update({
        'status': 'rejected',
        'approvedById': approvedById,
        'approvedByName': approvedByName,
        'approvedAt': FieldValue.serverTimestamp(),
        'notes': notes,
      });
    } catch (e) {
      throw Exception('Failed to reject time track: ${e.toString()}');
    }
  }

  // Create manual time track
  Future<TimeTrackModel> createManualTimeTrack({
    required String userId,
    required String userName,
    required DateTime checkIn,
    required DateTime checkOut,
    String? eventId,
    String? eventName,
    String? notes,
  }) async {
    try {
      String trackId = _uuid.v4();
      TimeTrackModel track = TimeTrackModel(
        id: trackId,
        userId: userId,
        userName: userName,
        checkIn: checkIn,
        checkOut: checkOut,
        eventId: eventId,
        eventName: eventName,
        isManualEntry: true,
        status: 'pending',
        notes: notes,
      );

      await _firestore
          .collection(AppConstants.timeTracksCollection)
          .doc(trackId)
          .set(track.toMap());

      return track;
    } catch (e) {
      throw Exception('Failed to create manual time track: ${e.toString()}');
    }
  }
}

