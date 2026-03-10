import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import 'api_service.dart';
import 'profile_service.dart';

class PostService extends ChangeNotifier {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  List<Post> _savedPosts = [];
  bool _isLoading = false;
  bool _isSavedLoading = false;

  List<Post> get posts => _posts;
  List<Post> get savedPosts => _savedPosts;
  bool get isLoading => _isLoading;
  bool get isSavedLoading => _isSavedLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/posts/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _posts = data.map((json) => Post.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns {'success': true, 'post': Post} or {'success': false, 'message': String}.
  Future<Map<String, dynamic>> createPost(
    String content, {
    int? projectId,
    http.MultipartFile? imageFile,
  }) async {
    try {
      if (ProfileService().myProfile == null) {
        await ProfileService().fetchMyProfile();
      }
      final currentUserId = ProfileService().myProfile?.user;
      if (currentUserId == null) {
        return {'success': false, 'message': 'Not logged in. Please sign in again.'};
      }

      final fields = <String, String>{
        'content': content,
        'user': currentUserId.toString(),
      };
      if (projectId != null) {
        fields['project'] = projectId.toString();
      }

      final response = await _apiService.postMultipart(
        '/posts/',
        fields,
        files: imageFile != null ? [imageFile] : null,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final post = Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        _posts.insert(0, post);
        notifyListeners();
        return {'success': true, 'post': post};
      }
      // Surface Django validation/error message
      String message = 'Failed to create post';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final first = body.values.firstOrNull;
          if (first is List && first.isNotEmpty) message = first.first.toString();
          else if (first != null) message = first.toString();
        }
      } catch (_) {}
      return {'success': false, 'message': message};
    } catch (e) {
      debugPrint('Error creating post: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<void> likePost(int id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final originalPost = _posts[index];
    final bool wasLiked = originalPost.isLiked;

    // Optimistic Update
    _posts[index] = originalPost.copyWith(
      isLiked: !wasLiked,
      likeCount: wasLiked
          ? originalPost.likeCount - 1
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
    return true;
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
        _savedPosts.add(_posts[idx]);
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

  Future<void> fetchComments(int postId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _comments = [
      Comment(
        id: 1,
        user: 2,
        username: 'alice_smith',
        fullName: 'Alice Smith',
        content: 'Wow, this looks amazing!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Comment(
        id: 2,
        user: 3,
        username: 'bob_builder',
        fullName: 'Bob Builder',
        content: 'Great work dev!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addComment(int postId, String content) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      user: 1,
      username: 'jasim_dev',
      fullName: 'Jasim VP',
      content: content,
      createdAt: DateTime.now(),
    );
    _comments.add(newComment);
    
    // Update comment count in post
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _posts[idx] = _posts[idx].copyWith(commentCount: _posts[idx].commentCount + 1);
    }

    notifyListeners();
    return true;
  }

  Future<Post?> fetchPostById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _posts.firstWhere((p) => p.id == id, orElse: () => _posts[0]);
  }

  Future<Post?> updatePost(int id, Map<String, dynamic> data) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      // Simulate update by creating a new post with updated data
      final updatedPost = _posts[index].copyWith(
        content: data['content'] as String? ?? _posts[index].content,
        // Add other fields as needed
      );
      _posts[index] = updatedPost;
      notifyListeners();
      return updatedPost;
    }
    return null;
  }

  Future<Post?> partialUpdatePost(int id, Map<String, dynamic> data) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      // Simulate partial update
      final updatedPost = _posts[index].copyWith(
        content: data['content'] as String? ?? _posts[index].content,
        // Add other fields as needed
      );
      _posts[index] = updatedPost;
      notifyListeners();
      return updatedPost;
    }
    return null;
  }

  Future<bool> deletePost(int id) async {
    try {
      final response = await _apiService.delete('/posts/$id/');
      if (response.statusCode == 204 || response.statusCode == 200) {
        _posts.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
    }
    return false;
  }

  void clear() {
    _posts = [];
    _savedPosts = [];
    _isLoading = false;
    notifyListeners();
  }
}
