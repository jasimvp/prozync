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

  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

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

  Future<Post?> createPost(
    String content, {
    int? projectId,
    http.MultipartFile? imageFile,
    int? userId,
  }) async {
    try {
      final fields = {
        'content': content,
        if (projectId != null) 'project': projectId.toString(),
        if (userId != null) 'user': userId.toString(),
      };

      final response = await _apiService.postMultipart(
        '/posts/',
        fields,
        files: imageFile != null ? [imageFile] : null,
      );

      if (response.statusCode == 201) {
        final post = Post.fromJson(jsonDecode(response.body));
        _posts.insert(0, post);
        notifyListeners();
        return post;
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
    }
    return null;
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
          : originalPost.likeCount + 1,
    );
    notifyListeners();

    try {
      final response = await _apiService.post('/posts/$id/like/', {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('id')) {
          _posts[index] = Post.fromJson(body as Map<String, dynamic>);
        }
        // If body doesn't have ID, we keep our optimistic state which is likely correct
      } else {
        // Rollback on failure
        _posts[index] = originalPost;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error liking post: $e');
      _posts[index] = originalPost;
      notifyListeners();
    }
  }

  Future<bool> toggleSavePost(int id) async {
    try {
      // Try with trailing slash first, common in Django
      final response = await _apiService.post('/posts/$id/save/', {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            isSaved: !_posts[index].isSaved,
          );
          notifyListeners();
        }
        return true;
      } else {
        debugPrint(
          'Save post failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error saving post: $e');
    }
    return false;
  }

  Future<List<Comment>> fetchComments(int postId) async {
    try {
      final response = await _apiService.get('/posts/$postId/comments/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }
    return [];
  }

  Future<Comment?> addComment(int postId, String content) async {
    try {
      final response = await _apiService.post('/posts/$postId/comment/', {
        'comment_text': content,
        'post': postId,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final comment = Comment.fromJson(jsonDecode(response.body));
        // Update local post comment count if possible
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            commentCount: _posts[index].commentCount + 1,
          );
        }
        notifyListeners();
        return comment;
      } else {
        debugPrint(
          'Add comment failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
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
}
