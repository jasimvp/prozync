import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import 'api_service.dart';

class PostService extends ChangeNotifier {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  List<Post> _posts = [];
  List<Post> _savedPosts = [];
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isSavedLoading = false;

  List<Post> get posts => _posts;
  List<Post> get savedPosts => _savedPosts;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isSavedLoading => _isSavedLoading;

  Future<void> fetchPosts({String? search, int? projectId}) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _posts = [
      Post(
        id: 1,
        user: 1,
        username: 'jasim_dev',
        fullName: 'Jasim VP',
        content: 'Check out my new project built with Flutter! 🚀 #prozync #flutter',
        likeCount: 15,
        commentCount: 2,
        isLiked: true,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 2,
        user: 2,
        username: 'alice_smith',
        fullName: 'Alice Smith',
        content: 'Just finished the backend API for my e-ecommerce site. Feeling great!',
        likeCount: 42,
        commentCount: 5,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    if (search != null && search.isNotEmpty) {
      _posts = _posts.where((p) => p.content.toLowerCase().contains(search.toLowerCase()) || p.username.toLowerCase().contains(search.toLowerCase())).toList();
    }
    
    if (projectId != null) {
      _posts = _posts.where((p) => p.project == projectId).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyPosts() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _posts = _posts.where((p) => p.user == 1).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createPost(
    String content, {
    int? projectId,
    http.MultipartFile? imageFile,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch,
      user: 1,
      username: 'jasim_dev',
      fullName: 'Jasim VP',
      content: content,
      project: projectId,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, newPost);
    notifyListeners();
    return {'success': true, 'post': newPost};
  }

  Future<bool> likePost(int postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final wasLiked = _posts[idx].isLiked;
      _posts[idx] = _posts[idx].copyWith(
        isLiked: !wasLiked,
        likeCount: wasLiked ? _posts[idx].likeCount - 1 : _posts[idx].likeCount + 1,
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> toggleSavePost(int postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _posts[idx] = _posts[idx].copyWith(isSaved: !_posts[idx].isSaved);
      if (_posts[idx].isSaved) {
        if (!_savedPosts.any((p) => p.id == postId)) {
          _savedPosts.insert(0, _posts[idx]);
        }
      } else {
        _savedPosts.removeWhere((p) => p.id == postId);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchSavedPosts() async {
    _isSavedLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _savedPosts = _posts.where((p) => p.isSaved).toList();
    _isSavedLoading = false;
    notifyListeners();
  }

  Future<List<Comment>> fetchComments(int postId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    final mockComments = [
      Comment(
        id: 1,
        user: 2,
        username: 'alice_smith',
        fullName: 'Alice Smith',
        content: 'Wow, this looks amazing!',
        post: postId,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Comment(
        id: 2,
        user: 3,
        username: 'bob_builder',
        fullName: 'Bob Builder',
        content: 'Great work dev!',
        post: postId,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
    _comments = mockComments;
    _isLoading = false;
    notifyListeners();
    return mockComments;
  }

  Future<Comment?> addComment(int postId, String content) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      user: 1,
      username: 'jasim_dev',
      fullName: 'Jasim VP',
      post: postId,
      content: content,
      createdAt: DateTime.now(),
    );
    _comments.add(newComment);
    
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _posts[idx] = _posts[idx].copyWith(commentCount: _posts[idx].commentCount + 1);
    }

    notifyListeners();
    return newComment;
  }

  Future<Post?> fetchPostById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _posts.firstWhere((p) => p.id == id, orElse: () => _posts.isNotEmpty ? _posts[0] : throw Exception('Not found'));
  }

  Future<Post?> updatePost(int id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updatedPost = _posts[index].copyWith(
        content: data['content'] as String? ?? _posts[index].content,
      );
      _posts[index] = updatedPost;
      notifyListeners();
      return updatedPost;
    }
    return null;
  }

  Future<Post?> partialUpdatePost(int id, Map<String, dynamic> data) async {
    return updatePost(id, data);
  }

  Future<bool> deletePost(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    _posts.removeWhere((p) => p.id == id);
    _savedPosts.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }

  void clear() {
    _posts = [];
    _savedPosts = [];
    _comments = [];
    _isLoading = false;
    notifyListeners();
  }
}
