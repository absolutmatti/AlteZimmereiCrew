import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final Map<String, AttendanceStatus> attendees;
  final String? protocolUrl;
  final String createdById;
  final String createdByName;

  MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.attendees,
    this.protocolUrl,
    required this.createdById,
    required this.createdByName,
  });

  factory MeetingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    Map<String, AttendanceStatus> attendeesMap = {};
    if (data['attendees'] != null) {
      (data['attendees'] as Map<String, dynamic>).forEach((key, value) {
        attendeesMap[key] = AttendanceStatus.fromMap(value as Map<String, dynamic>);
      });
    }
    
    return MeetingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      attendees: attendeesMap,
      protocolUrl: data['protocolUrl'],
      createdById: data['createdById'] ?? '',
      createdByName: data['createdByName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> attendeesMap = {};
    attendees.forEach((key, value) {
      attendeesMap[key] = value.toMap();
    });
    
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'attendees': attendeesMap,
      'protocolUrl': protocolUrl,
      'createdById': createdById,
      'createdByName': createdByName,
    };
  }

  MeetingModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? location,
    Map<String, AttendanceStatus>? attendees,
    String? protocolUrl,
  }) {
    return MeetingModel(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      protocolUrl: protocolUrl ?? this.protocolUrl,
      createdById: this.createdById,
      createdByName: this.createdByName,
    );
  }
}

class AttendanceStatus {
  final String status; // 'attending', 'not_attending', 'pending'
  final String? reason;
  final DateTime updatedAt;

  AttendanceStatus({
    required this.status,
    this.reason,
    required this.updatedAt,
  });

  factory AttendanceStatus.fromMap(Map<String, dynamic> data) {
    return AttendanceStatus(
      status: data['status'] ?? 'pending',
      reason: data['reason'],
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'reason': reason,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

