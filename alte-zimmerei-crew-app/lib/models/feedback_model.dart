import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;
  final String status; // 'pending', 'read', 'responded'
  final String? responseMessage;
  final String? respondedById;
  final String? respondedByName;
  final DateTime? respondedAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
    required this.status,
    this.responseMessage,
    this.respondedById,
    this.respondedByName,
    this.respondedAt,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return FeedbackModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      responseMessage: data['responseMessage'],
      respondedById: data['respondedById'],
      respondedByName: data['respondedByName'],
      respondedAt: data['respondedAt'] != null ? (data['respondedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'responseMessage': responseMessage,
      'respondedById': respondedById,
      'respondedByName': respondedByName,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  FeedbackModel copyWith({
    String? status,
    String? responseMessage,
    String? respondedById,
    String? respondedByName,
    DateTime? respondedAt,
  }) {
    return FeedbackModel(
      id: this.id,
      userId: this.userId,
      userName: this.userName,
      message: this.message,
      createdAt: this.createdAt,
      status: status ?? this.status,
      responseMessage: responseMessage ?? this.responseMessage,
      respondedById: respondedById ?? this.respondedById,
      respondedByName: respondedByName ?? this.respondedByName,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

