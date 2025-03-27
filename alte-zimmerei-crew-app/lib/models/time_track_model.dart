import 'package:cloud_firestore/cloud_firestore.dart';

class TimeTrackModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? eventId;
  final String? eventName;
  final bool isManualEntry;
  final String status; // 'pending', 'approved', 'rejected'
  final String? approvedById;
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? notes;

  TimeTrackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.checkIn,
    this.checkOut,
    this.eventId,
    this.eventName,
    required this.isManualEntry,
    required this.status,
    this.approvedById,
    this.approvedByName,
    this.approvedAt,
    this.notes,
  });

  factory TimeTrackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TimeTrackModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: data['checkOut'] != null ? (data['checkOut'] as Timestamp).toDate() : null,
      eventId: data['eventId'],
      eventName: data['eventName'],
      isManualEntry: data['isManualEntry'] ?? false,
      status: data['status'] ?? 'pending',
      approvedById: data['approvedById'],
      approvedByName: data['approvedByName'],
      approvedAt: data['approvedAt'] != null ? (data['approvedAt'] as Timestamp).toDate() : null,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'eventId': eventId,
      'eventName': eventName,
      'isManualEntry': isManualEntry,
      'status': status,
      'approvedById': approvedById,
      'approvedByName': approvedByName,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'notes': notes,
    };
  }

  TimeTrackModel copyWith({
    DateTime? checkOut,
    String? status,
    String? approvedById,
    String? approvedByName,
    DateTime? approvedAt,
    String? notes,
  }) {
    return TimeTrackModel(
      id: this.id,
      userId: this.userId,
      userName: this.userName,
      checkIn: this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      eventId: this.eventId,
      eventName: this.eventName,
      isManualEntry: this.isManualEntry,
      status: status ?? this.status,
      approvedById: approvedById ?? this.approvedById,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedAt: approvedAt ?? this.approvedAt,
      notes: notes ?? this.notes,
    );
  }

  Duration getDuration() {
    if (checkOut == null) {
      return Duration.zero;
    }
    return checkOut!.difference(checkIn);
  }

  String getFormattedDuration() {
    Duration duration = getDuration();
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}

