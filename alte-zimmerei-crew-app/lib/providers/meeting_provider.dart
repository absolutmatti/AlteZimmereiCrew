import 'package:flutter/material.dart';
import 'dart:io';
import '../models/meeting_model.dart';
import '../services/meeting_service.dart';

class MeetingProvider extends ChangeNotifier {
  final MeetingService _meetingService = MeetingService();
  List<MeetingModel> _meetings = [];
  List<MeetingModel> _upcomingMeetings = [];
  bool _isLoading = false;
  String? _error;

  List<MeetingModel> get meetings => _meetings;
  List<MeetingModel> get upcomingMeetings => _upcomingMeetings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize meetings
  void initializeMeetings() {
    // Listen to all meetings stream
    _meetingService.getAllMeetingsStream().listen((meetings) {
      _meetings = meetings;
      notifyListeners();
    });

    // Listen to upcoming meetings stream
    _meetingService.getUpcomingMeetingsStream().listen((meetings) {
      _upcomingMeetings = meetings;
      notifyListeners();
    });
  }

  // Create meeting
  Future<void> createMeeting({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String createdById,
    required String createdByName,
    required List<String> attendeeIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _meetingService.createMeeting(
        title: title,
        description: description,
        date: date,
        location: location,
        createdById: createdById,
        createdByName: createdByName,
        attendeeIds: attendeeIds,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update meeting
  Future<void> updateMeeting(MeetingModel meeting) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _meetingService.updateMeeting(meeting);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete meeting
  Future<void> deleteMeeting(String meetingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _meetingService.deleteMeeting(meetingId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update attendance status
  Future<void> updateAttendanceStatus(
      String meetingId, String userId, String status, String? reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _meetingService.updateAttendanceStatus(meetingId, userId, status, reason);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload protocol
  Future<void> uploadProtocol(String meetingId, File protocolFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _meetingService.uploadProtocol(meetingId, protocolFile);
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

