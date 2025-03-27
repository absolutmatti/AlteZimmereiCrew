import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String name;
  final DateTime date;
  final String description;
  final String? flyerUrl;
  final Map<String, String> staff; // Map of role to userId
  final Map<String, String> djs; // Map of slot to name
  final bool isPublished;
  final String createdById;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    this.flyerUrl,
    required this.staff,
    required this.djs,
    required this.isPublished,
    required this.createdById,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return EventModel(
      id: doc.id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      flyerUrl: data['flyerUrl'],
      staff: Map<String, String>.from(data['staff'] ?? {}),
      djs: Map<String, String>.from(data['djs'] ?? {}),
      isPublished: data['isPublished'] ?? false,
      createdById: data['createdById'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'description': description,
      'flyerUrl': flyerUrl,
      'staff': staff,
      'djs': djs,
      'isPublished': isPublished,
      'createdById': createdById,
    };
  }

  EventModel copyWith({
    String? name,
    DateTime? date,
    String? description,
    String? flyerUrl,
    Map<String, String>? staff,
    Map<String, String>? djs,
    bool? isPublished,
  }) {
    return EventModel(
      id: this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      description: description ?? this.description,
      flyerUrl: flyerUrl ?? this.flyerUrl,
      staff: staff ?? this.staff,
      djs: djs ?? this.djs,
      isPublished: isPublished ?? this.isPublished,
      createdById: this.createdById,
    );
  }
}

