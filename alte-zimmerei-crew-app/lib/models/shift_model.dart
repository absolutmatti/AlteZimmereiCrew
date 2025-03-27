import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftModel {
  final String id;
  final String eventId;
  final String eventName;
  final DateTime date;
  final String shiftType; // e.g., 'bartender', 'security', 'dj'
  final String assignedToId;
  final String assignedToName;
  final String? originalAssignedToId;
  final String? originalAssignedToName;
  final String status; // 'assigned', 'requested_change', 'change_approved'
  final String? changeRequestReason;
  final List<ShiftChangeOffer>? changeOffers;

  ShiftModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.date,
    required this.shiftType,
    required this.assignedToId,
    required this.assignedToName,
    this.originalAssignedToId,
    this.originalAssignedToName,
    required this.status,
    this.changeRequestReason,
    this.changeOffers,
  });

  factory ShiftModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    List<ShiftChangeOffer>? offers;
    if (data['changeOffers'] != null) {
      offers = (data['changeOffers'] as List).map((offer) => 
        ShiftChangeOffer.fromMap(offer as Map<String, dynamic>)
      ).toList();
    }
    
    return ShiftModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      shiftType: data['shiftType'] ?? '',
      assignedToId: data['assignedToId'] ?? '',
      assignedToName: data['assignedToName'] ?? '',
      originalAssignedToId: data['originalAssignedToId'],
      originalAssignedToName: data['originalAssignedToName'],
      status: data['status'] ?? 'assigned',
      changeRequestReason: data['changeRequestReason'],
      changeOffers: offers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'date': Timestamp.fromDate(date),
      'shiftType': shiftType,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'originalAssignedToId': originalAssignedToId,
      'originalAssignedToName': originalAssignedToName,
      'status': status,
      'changeRequestReason': changeRequestReason,
      'changeOffers': changeOffers?.map((offer) => offer.toMap()).toList(),
    };
  }

  ShiftModel copyWith({
    String? eventId,
    String? eventName,
    DateTime? date,
    String? shiftType,
    String? assignedToId,
    String? assignedToName,
    String? originalAssignedToId,
    String? originalAssignedToName,
    String? status,
    String? changeRequestReason,
    List<ShiftChangeOffer>? changeOffers,
  }) {
    return ShiftModel(
      id: this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      date: date ?? this.date,
      shiftType: shiftType ?? this.shiftType,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      originalAssignedToId: originalAssignedToId ?? this.originalAssignedToId,
      originalAssignedToName: originalAssignedToName ?? this.originalAssignedToName,
      status: status ?? this.status,
      changeRequestReason: changeRequestReason ?? this.changeRequestReason,
      changeOffers: changeOffers ?? this.changeOffers,
    );
  }
}

class ShiftChangeOffer {
  final String userId;
  final String userName;
  final DateTime offerDate;
  final String? message;

  ShiftChangeOffer({
    required this.userId,
    required this.userName,
    required this.offerDate,
    this.message,
  });

  factory ShiftChangeOffer.fromMap(Map<String, dynamic> data) {
    return ShiftChangeOffer(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      offerDate: (data['offerDate'] as Timestamp).toDate(),
      message: data['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'offerDate': Timestamp.fromDate(offerDate),
      'message': message,
    };
  }
}

