import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Create a new post
  Future<PostModel> createPost({
    required String authorId,
    required String authorName,
    String? authorImageUrl,
    required String content,
    List<File>? mediaFiles,
    required String type,
    List<String>? tags,
    required bool isImportant,
    Map<String, dynamic>? pollData,
    required String feedType,
  }) async {
    try {
      // Upload media files if any
      List<String>? mediaUrls;
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        mediaUrls = await _uploadMediaFiles(mediaFiles, type);
      }

      // Create post document
      String postId = _uuid.v4();
      PostModel post = PostModel(
        id: postId,
        authorId: authorId,
        authorName: authorName,
        authorImageUrl: authorImageUrl,
        content: content,
        mediaUrls: mediaUrls,
        type: type,
        tags: tags,
        isPinned: false,
        isImportant: isImportant,
        createdAt: DateTime.now(),
        pollData: pollData,
        feedType: feedType,
      );

      // Save to Firestore
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      await _firestore
          .collection(collectionName)
          .doc(postId)
          .set(post.toMap());

      return post;
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  // Upload media files
  Future<List<String>> _uploadMediaFiles(List<File> files, String type) async {
    List<String> urls = [];
    
    for (int i = 0; i < files.length; i++) {
      File file = files[i];
      String fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';
      String path = type == AppConstants.postTypeVideo 
          ? '${AppConstants.postVideosPath}/$fileName' 
          : '${AppConstants.postImagesPath}/$fileName';
      
      UploadTask uploadTask = _storage.ref().child(path).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      urls.add(downloadUrl);
    }
    
    return urls;
  }

  // Get posts stream
  Stream<List<PostModel>> getPostsStream(String feedType) {
    String collectionName = feedType == 'news' 
        ? AppConstants.newsPostsCollection 
        : AppConstants.generalPostsCollection;
    
    return _firestore
        .collection(collectionName)
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }

  // Get post by ID
  Future<PostModel> getPostById(String postId, String feedType) async {
    try {
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(postId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Post not found');
      }
      
      return PostModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get post: ${e.toString()}');
    }
  }

  // Update post
  Future<void> updatePost(PostModel post) async {
    try {
      String collectionName = post.feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      await _firestore
          .collection(collectionName)
          .doc(post.id)
          .update(post.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update post: ${e.toString()}');
    }
  }

  // Delete post
  Future<void> deletePost(String postId, String feedType) async {
    try {
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      // Delete post document
      await _firestore.collection(collectionName).doc(postId).delete();
      
      // Delete comments
      QuerySnapshot commentsSnapshot = await _firestore
          .collection('$collectionName/$postId/comments')
          .get();
      
      for (DocumentSnapshot doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Note: In a production app, you would also delete media files from storage
    } catch (e) {
      throw Exception('Failed to delete post: ${e.toString()}');
    }
  }

  // Pin/unpin post
  Future<void> togglePinPost(String postId, String feedType, bool isPinned) async {
    try {
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      await _firestore
          .collection(collectionName)
          .doc(postId)
          .update({'isPinned': isPinned});
    } catch (e) {
      throw Exception('Failed to toggle pin status: ${e.toString()}');
    }
  }

  // Add reaction to post
  Future<void> addReactionToPost(
      String postId, String feedType, String userId, String reaction) async {
    try {
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      // Get current post
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(postId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Post not found');
      }
      
      PostModel post = PostModel.fromFirestore(doc);
      
      // Update reactions
      Map<String, List<String>> reactions = post.reactions ?? {};
      
      // Remove user from all reactions first
      reactions.forEach((key, userList) {
        if (userList.contains(userId)) {
          userList.remove(userId);
        }
      });
      
      // Add user to the selected reaction
      if (!reactions.containsKey(reaction)) {
        reactions[reaction] = [];
      }
      reactions[reaction]!.add(userId);
      
      // Update post
      await _firestore
          .collection(collectionName)
          .doc(postId)
          .update({'reactions': reactions});
    } catch (e) {
      throw Exception('Failed to add reaction: ${e.toString()}');
    }
  }

  // Add comment to post
  Future<CommentModel> addComment(
      String postId, String feedType, String authorId, String authorName, 
      String? authorImageUrl, String content) async {
    try {
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      // Create comment
      String commentId = _uuid.v4();
      CommentModel comment = CommentModel(
        id: commentId,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorImageUrl: authorImageUrl,
        content: content,
        createdAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore
          .collection('$collectionName/$postId/comments')
          .doc(commentId)
          .set(comment.toMap());
      
      return comment;
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  // Get comments for a post
  Stream<List<CommentModel>> getCommentsStream(String postId, String feedType) {
    String collectionName = feedType == 'news' 
        ? AppConstants.newsPostsCollection 
        : AppConstants.generalPostsCollection;
    
    return _firestore
        .collection('$collectionName/$postId/comments')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  // Vote in poll
  Future<void> voteInPoll(
      String postId, String feedType, String userId, String optionId) async {
    try {
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      // Get current post
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(postId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Post not found');
      }
      
      PostModel post = PostModel.fromFirestore(doc);
      
      if (post.pollData == null) {
        throw Exception('Post is not a poll');
      }
      
      // Update poll data
      Map<String, dynamic> pollData = Map<String, dynamic>.from(post.pollData!);
      
      // Remove user from all options first
      if (pollData.containsKey('options')) {
        List<Map<String, dynamic>> options = List<Map<String, dynamic>>.from(pollData['options']);
        
        for (var option in options) {
          if (option.containsKey('votes') && option['votes'] is List) {
            List<String> votes = List<String>.from(option['votes']);
            if (votes.contains(userId)) {
              votes.remove(userId);
              option['votes'] = votes;
            }
          }
        }
        
        // Add user to the selected option
        for (var option in options) {
          if (option['id'] == optionId) {
            if (!option.containsKey('votes') || option['votes'] == null) {
              option['votes'] = [];
            }
            List<String> votes = List<String>.from(option['votes']);
            votes.add(userId);
            option['votes'] = votes;
          }
        }
        
        pollData['options'] = options;
      }
      
      // Update post
      await _firestore
          .collection(collectionName)
          .doc(postId)
          .update({'pollData': pollData});
    } catch (e) {
      throw Exception('Failed to vote in poll: ${e.toString()}');
    }
  }

  // Search posts
  Future<List<PostModel>> searchPosts(String query, String feedType) async {
    try {
      String collectionName = feedType == 'news' 
          ? AppConstants.newsPostsCollection 
          : AppConstants.generalPostsCollection;
      
      // This is a simple implementation. In a production app, you would use
      // a more sophisticated search solution like Algolia or Elasticsearch.
      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      
      List<PostModel> allPosts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
      
      // Filter posts that contain the query in content, author name, or tags
      return allPosts.where((post) {
        bool matchesContent = post.content.toLowerCase().contains(query.toLowerCase());
        bool matchesAuthor = post.authorName.toLowerCase().contains(query.toLowerCase());
        bool matchesTags = post.tags != null && post.tags!.any(
            (tag) => tag.toLowerCase().contains(query.toLowerCase()));
        
        return matchesContent || matchesAuthor || matchesTags;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search posts: ${e.toString()}');
    }
  }
}

