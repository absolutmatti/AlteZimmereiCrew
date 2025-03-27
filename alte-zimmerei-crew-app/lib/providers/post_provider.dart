import 'package:flutter/material.dart';
import 'dart:io';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  List<PostModel> _newsPosts = [];
  List<PostModel> _generalPosts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get newsPosts => _newsPosts;
  List<PostModel> get generalPosts => _generalPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize posts
  void initializePosts() {
    // Listen to news posts stream
    _postService.getPostsStream('news').listen((posts) {
      _newsPosts = posts;
      notifyListeners();
    });

    // Listen to general posts stream
    _postService.getPostsStream('general').listen((posts) {
      _generalPosts = posts;
      notifyListeners();
    });
  }

  // Create post
  Future<void> createPost({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.createPost(
        authorId: authorId,
        authorName: authorName,
        authorImageUrl: authorImageUrl,
        content: content,
        mediaFiles: mediaFiles,
        type: type,
        tags: tags,
        isImportant: isImportant,
        pollData: pollData,
        feedType: feedType,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update post
  Future<void> updatePost(PostModel post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.updatePost(post);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete post
  Future<void> deletePost(String postId, String feedType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.deletePost(postId, feedType);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle pin post
  Future<void> togglePinPost(String postId, String feedType, bool isPinned) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.togglePinPost(postId, feedType, isPinned);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add reaction to post
  Future<void> addReactionToPost(
      String postId, String feedType, String userId, String reaction) async {
    _error = null;

    try {
      await _postService.addReactionToPost(postId, feedType, userId, reaction);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add comment to post
  Future<void> addComment(
      String postId, String feedType, String authorId, String authorName, 
      String? authorImageUrl, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.addComment(
          postId, feedType, authorId, authorName, authorImageUrl, content);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vote in poll
  Future<void> voteInPoll(
      String postId, String feedType, String userId, String optionId) async {
    _error = null;

    try {
      await _postService.voteInPoll(postId, feedType, userId, optionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Search posts
  Future<List<PostModel>> searchPosts(String query, String feedType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<PostModel> results = await _postService.searchPosts(query, feedType);
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

