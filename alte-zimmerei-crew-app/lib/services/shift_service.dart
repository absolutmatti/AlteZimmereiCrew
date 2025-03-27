import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class ShiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Create a new shift
  Future<ShiftModel> createShift({
    required String eventId,
    required String eventName,
    required DateTime date,
    required String shiftType,
    required String assignedToId,
    required String assignedToName,
  }) async {
    try {
      String shiftId = _uuid.v4();
      ShiftModel shift = ShiftModel(
        id: shiftId,
        eventId: eventId,
        eventName: eventName,
        date: date,
        shiftType: shiftType,
        assignedToId: assignedToId,
        assignedToName: assignedToName,
        status: 'assigned',
      );

      await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .set(shift.toMap());

      return shift;
    } catch (e) {
      throw Exception('Failed to create shift: ${e.toString()}');
    }
  }

  // Get user shifts stream
  Stream<List<ShiftModel>> getUserShiftsStream(String userId) {
    return _firestore
        .collection(AppConstants.shiftsCollection)
        .where('assignedToId', isEqualTo: userId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShiftModel.fromFirestore(doc))
            .toList());
  }

  // Get all shifts stream
  Stream<List<ShiftModel>> getAllShiftsStream() {
    return _firestore
        .collection(AppConstants.shiftsCollection)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShiftModel.fromFirestore(doc))
            .toList());
  }

  // Get shift by ID
  Future<ShiftModel> getShiftById(String shiftId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Shift not found');
      }
      
      return ShiftModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get shift: ${e.toString()}');
    }
  }

  // Request shift change
  Future<void> requestShiftChange(String shiftId, String reason) async {
    try {
      await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .update({
        'status': 'requested_change',
        'changeRequestReason': reason,
      });
    } catch (e) {
      throw Exception('Failed to request shift change: ${e.toString()}');
    }
  }

  // Offer to take shift
  Future<void> offerToTakeShift(
      String shiftId, String userId, String userName, String? message) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Shift not found');
      }
      
      ShiftModel shift = ShiftModel.fromFirestore(doc);
      
      List<ShiftChangeOffer> offers = shift.changeOffers ?? [];
      
      // Check if user already has an offer
      bool hasExistingOffer = offers.any((offer) => offer.userId == userId);
      
      if (!hasExistingOffer) {
        ShiftChangeOffer newOffer = ShiftChangeOffer(
          userId: userId,
          userName: userName,
          offerDate: DateTime.now(),
          message: message,
        );
        
        offers.add(newOffer);
        
        await _firestore
            .collection(AppConstants.shiftsCollection)
            .doc(shiftId)
            .update({
          'changeOffers': offers.map((offer) => offer.toMap()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to offer to take shift: ${e.toString()}');
    }
  }

  // Approve shift change
  Future<void> approveShiftChange(
      String shiftId, String newUserId, String newUserName) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Shift not found');
      }
      
      ShiftModel shift = ShiftModel.fromFirestore(doc);
      
      await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .update({
        'status': 'change_approved',
        'originalAssignedToId': shift.assignedToId,
        'originalAssignedToName': shift.assignedToName,
        'assignedToId': newUserId,
        'assignedToName': newUserName,
      });
    } catch (e) {
      throw Exception('Failed to approve shift change: ${e.toString()}');
    }
  }

  // Reject shift change
  Future<void> rejectShiftChange(String shiftId) async {
    try {
      await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .update({
        'status': 'assigned',
        'changeRequestReason': null,
        'changeOffers': [],
      });
    } catch (e) {
      throw Exception('Failed to reject shift change: ${e.toString()}');
    }
  }

  // Delete shift
  Future<void> deleteShift(String shiftId) async {
    try {
      await _firestore
          .collection(AppConstants.shiftsCollection)
          .doc(shiftId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete shift: ${e.toString()}');
    }
  }
}

