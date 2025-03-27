import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/meeting_model.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Create a new meeting
  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String createdById,
    required String createdByName,
    required List<String> attendeeIds,
  }) async {
    try {
      String meetingId = _uuid.v4();
      
      // Create attendees map
      Map<String, AttendanceStatus> attendees = {};
      for (String userId in attendeeIds) {
        attendees[userId] = AttendanceStatus(
          status: 'pending',
          updatedAt: DateTime.now(),
        );
      }
      
      MeetingModel meeting = MeetingModel(
        id: meetingId,
        title: title,
        description: description,
        date: date,
        location: location,
        attendees: attendees,
        createdById: createdById,
        createdByName: createdByName,
      );

      await _firestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .set(meeting.toMap());

      return meeting;
    } catch (e) {
      throw Exception('Failed to create meeting: ${e.toString()}');
    }
  }

  // Get all meetings
  Stream<List<MeetingModel>> getAllMeetingsStream() {
    return _firestore
        .collection(AppConstants.meetingsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MeetingModel.fromFirestore(doc))
            .toList());
  }

  // Get upcoming meetings
  Stream<List<MeetingModel>> getUpcomingMeetingsStream() {
    return _firestore
        .collection(AppConstants.meetingsCollection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MeetingModel.fromFirestore(doc))
            .toList());
  }

  // Get meeting by ID
  Future<MeetingModel> getMeetingById(String meetingId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Meeting not found');
      }
      
      return MeetingModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get meeting: ${e.toString()}');
    }
  }

  // Update meeting
  Future<void> updateMeeting(MeetingModel meeting) async {
    try {
      await _firestore
          .collection(AppConstants.meetingsCollection)
          .doc(meeting.id)
          .update(meeting.toMap());
    } catch (e) {
      throw Exception('Failed to update meeting: ${e.toString()}');
    }
  }

  // Delete meeting
  Future<void> deleteMeeting(String meetingId) async {
    try {
      await _firestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete meeting: ${e.toString()}');
    }
  }

  // Update attendance status
  Future<void> updateAttendanceStatus(
      String meetingId, String userId, String status, String? reason) async {
    try {
      // Get current meeting
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Meeting not found');
      }
      
      MeetingModel meeting = MeetingModel.fromFirestore(doc);
      
      // Update attendees
      Map<String, AttendanceStatus> attendees = Map.from(meeting.attendees);
      attendees[userId] = AttendanceStatus(
        status: status,
        reason: reason,
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .update({'attendees': attendees.map((key, value) => MapEntry(key, value.toMap()))});
    } catch (e) {
      throw Exception('Failed to update attendance status: ${e.toString()}');
    }
  }

  // Upload protocol
  Future<void> uploadProtocol(String meetingId, File protocolFile) async {
    try {
      String fileName = 'protocol_${meetingId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String path = 'meeting_protocols/$fileName';
      
      UploadTask uploadTask = _storage.ref().child(path).putFile(protocolFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      await _firestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .update({'protocolUrl': downloadUrl});
    } catch (e) {
      throw Exception('Failed to upload protocol: ${e.toString()}');
    }
  }
}

