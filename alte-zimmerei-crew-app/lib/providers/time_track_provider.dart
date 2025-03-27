import 'package:flutter/material.dart';
import '../models/time_track_model.dart';
import '../services/time_track_service.dart';

class TimeTrackProvider extends ChangeNotifier {
  final TimeTrackService _timeTrackService = TimeTrackService();
  List<TimeTrackModel> _userTimeTracks = [];
  List<TimeTrackModel> _allTimeTracks = [];
  List<TimeTrackModel> _pendingTimeTracks = [];
  TimeTrackModel? _activeTimeTrack;
  bool _isLoading = false;
  String? _error;

  List<TimeTrackModel> get userTimeTracks => _userTimeTracks;
  List<TimeTrackModel> get allTimeTracks => _allTimeTracks;
  List<TimeTrackModel> get pendingTimeTracks => _pendingTimeTracks;
  TimeTrackModel? get activeTimeTrack => _activeTimeTrack;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize time tracks for a user
  void initializeUserTimeTracks(String userId) {
    // Listen to user time tracks stream
    _timeTrackService.getUserTimeTracksStream(userId).listen((timeTracks) {
      _userTimeTracks = timeTracks;
      notifyListeners();
    });

    // Check for active time track
    _checkActiveTimeTrack(userId);
  }

  // Initialize all time tracks (for admin)
  void initializeAllTimeTracks() {
    // Listen to all time tracks stream
    _timeTrackService.getAllTimeTracksStream().listen((timeTracks) {
      _allTimeTracks = timeTracks;
      notifyListeners();
    });

    // Listen to pending time tracks stream
    _timeTrackService.getPendingTimeTracksStream().listen((timeTracks) {
      _pendingTimeTracks = timeTracks;
      notifyListeners();
    });
  }

  // Check for active time track
  Future<void> _checkActiveTimeTrack(String userId) async {
    try {
      _activeTimeTrack = await _timeTrackService.getActiveTimeTrack(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check in
  Future<void> checkIn({
    required String userId,
    required String userName,
    String? eventId,
    String? eventName,
    required bool isManualEntry,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeTimeTrack = await _timeTrackService.checkIn(
        userId: userId,
        userName: userName,
        eventId: eventId,
        eventName: eventName,
        isManualEntry: isManualEntry,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check out
  Future<void> checkOut() async {
    if (_activeTimeTrack == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _timeTrackService.checkOut(_activeTimeTrack!.id);
      _activeTimeTrack = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve time track
  Future<void> approveTimeTrack(
      String trackId, String approvedById, String approvedByName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _timeTrackService.approveTimeTrack(trackId, approvedById, approvedByName);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject time track
  Future<void> rejectTimeTrack(
      String trackId, String approvedById, String approvedByName, String notes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _timeTrackService.rejectTimeTrack(trackId, approvedById, approvedByName, notes);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create manual time track
  Future<void> createManualTimeTrack({
    required String userId,
    required String userName,
    required DateTime checkIn,
    required DateTime checkOut,
    String? eventId,
    String? eventName,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _timeTrackService.createManualTimeTrack(
        userId: userId,
        userName: userName,
        checkIn: checkIn,
        checkOut: checkOut,
        eventId: eventId,
        eventName: eventName,
        notes: notes,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh active time track
  Future<void> refreshActiveTimeTrack(String userId) async {
    await _checkActiveTimeTrack(userId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

