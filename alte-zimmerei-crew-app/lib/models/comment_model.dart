import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String content;
  final DateTime createdAt;
  final Map<String, List<String>>? reactions;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.content,
    required this.createdAt,
    this.reactions,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorImageUrl: data['authorImageUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reactions: data['reactions'] != null 
          ? Map<String, List<String>>.from(
              data['reactions'].map((key, value) => 
                MapEntry(key, List<String>.from(value))
              )
            ) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'reactions': reactions,
    };
  }
}

