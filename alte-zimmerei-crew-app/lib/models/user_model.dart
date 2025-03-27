import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String role;
  final String? profileImageUrl;
  final List<String> notificationPreferences;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    required this.notificationPreferences,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'],
      role: data['role'] ?? 'employee',
      profileImageUrl: data['profileImageUrl'],
      notificationPreferences: List<String>.from(data['notificationPreferences'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'notificationPreferences': notificationPreferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  UserModel copyWith({
    String? email,
    String? name,
    String? phoneNumber,
    String? role,
    String? profileImageUrl,
    List<String>? notificationPreferences,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      createdAt: this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  bool isOwner() {
    return role == 'owner';
  }
}

