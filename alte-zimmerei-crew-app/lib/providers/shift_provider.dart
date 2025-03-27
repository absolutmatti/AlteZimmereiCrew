import 'package:flutter/material.dart';
import '../models/shift_model.dart';
import '../services/shift_service.dart';

class ShiftProvider extends ChangeNotifier {
  final ShiftService _shiftService = ShiftService();
  List<ShiftModel> _userShifts = [];
  List<ShiftModel> _allShifts = [];
  bool _isLoading = false;
  String? _error;

  List<ShiftModel> get userShifts => _userShifts;
  List<ShiftModel> get allShifts => _allShifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize shifts for a user
  void initializeUserShifts(String userId) {
    _shiftService.getUserShiftsStream(userId).listen((shifts) {
      _userShifts = shifts;
      notifyListeners();
    });
  }

  // Initialize all shifts (for admin)
  void initializeAllShifts() {
    _shiftService.getAllShiftsStream().listen((shifts) {
      _allShifts = shifts;
      notifyListeners();
    });
  }

  // Create shift
  Future<void> createShift({
    required String eventId,
    required String eventName,
    required DateTime date,
    required String shiftType,
    required String assignedToId,
    required String assignedToName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shiftService.createShift(
        eventId: eventId,
        eventName: eventName,
        date: date,
        shiftType: shiftType,
        assignedToId: assignedToId,
        assignedToName: assignedToName,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request shift change
  Future<void> requestShiftChange(String shiftId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shiftService.requestShiftChange(shiftId, reason);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Offer to take shift
  Future<void> offerToTakeShift(
      String shiftId, String userId, String userName, String? message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shiftService.offerToTakeShift(shiftId, userId, userName, message);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve shift change
  Future<void> approveShiftChange(
      String shiftId, String newUserId, String newUserName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shiftService.approveShiftChange(shiftId, newUserId, newUserName);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject shift change
  Future<void> rejectShiftChange(String shiftId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shiftService.rejectShiftChange(shiftId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete shift
  Future<void> deleteShift(String shiftId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shiftService.deleteShift(shiftId);
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

