import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String content;
  final List<String>? mediaUrls;
  final String type;
  final List<String>? tags;
  final bool isPinned;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? pollData;
  final Map<String, List<String>>? reactions;
  final String feedType; // 'news' or 'general'

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.content,
    this.mediaUrls,
    required this.type,
    this.tags,
    required this.isPinned,
    required this.isImportant,
    required this.createdAt,
    this.updatedAt,
    this.pollData,
    this.reactions,
    required this.feedType,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorImageUrl: data['authorImageUrl'],
      content: data['content'] ?? '',
      mediaUrls: data['mediaUrls'] != null ? List<String>.from(data['mediaUrls']) : null,
      type: data['type'] ?? 'text',
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      isPinned: data['isPinned'] ?? false,
      isImportant: data['isImportant'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      pollData: data['pollData'],
      reactions: data['reactions'] != null 
          ? Map<String, List<String>>.from(
              data['reactions'].map((key, value) => 
                MapEntry(key, List<String>.from(value))
              )
            ) 
          : null,
      feedType: data['feedType'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'content': content,
      'mediaUrls': mediaUrls,
      'type': type,
      'tags': tags,
      'isPinned': isPinned,
      'isImportant': isImportant,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'pollData': pollData,
      'reactions': reactions,
      'feedType': feedType,
    };
  }

  PostModel copyWith({
    String? content,
    List<String>? mediaUrls,
    String? type,
    List<String>? tags,
    bool? isPinned,
    bool? isImportant,
    DateTime? updatedAt,
    Map<String, dynamic>? pollData,
    Map<String, List<String>>? reactions,
  }) {
    return PostModel(
      id: this.id,
      authorId: this.authorId,
      authorName: this.authorName,
      authorImageUrl: this.authorImageUrl,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isImportant: isImportant ?? this.isImportant,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      pollData: pollData ?? this.pollData,
      reactions: reactions ?? this.reactions,
      feedType: this.feedType,
    );
  }
}

