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
      final response = await _apiService.post('/posts/$id/save_post/', {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _posts.indexWhere((p) => p.id == id);
        final savedIndex = _savedPosts.indexWhere((p) => p.id == id);

        if (index != -1) {
          final wasSaved = _posts[index].isSaved;
          _posts[index] = _posts[index].copyWith(isSaved: !wasSaved);

          if (wasSaved) {
            _savedPosts.removeWhere((p) => p.id == id);
          } else {
            _savedPosts.insert(0, _posts[index]);
          }
        } else if (savedIndex != -1) {
          _savedPosts.removeAt(savedIndex);
        }

        notifyListeners();
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

  Future<void> fetchSavedPosts() async {
    _isSavedLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/posts/my_saved/');
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          _savedPosts = decoded.map((json) => Post.fromJson(json)).toList();
        } else if (decoded is Map && decoded.containsKey('results')) {
          final List<dynamic> data = decoded['results'];
          _savedPosts = data.map((json) => Post.fromJson(json)).toList();
        }
      } else {
        debugPrint(
          'Fetch saved posts failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching saved posts: $e');
    } finally {
      _isSavedLoading = false;
      notifyListeners();
    }
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

  Future<Post?> fetchPostById(int id) async {
    try {
      final response = await _apiService.get('/posts/$id/');
      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching post $id: $e');
    }
    return null;
  }

  Future<Post?> updatePost(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/posts/$id/', data);
      if (response.statusCode == 200) {
        final updatedPost = Post.fromJson(jsonDecode(response.body));
        final index = _posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
        return updatedPost;
      }
    } catch (e) {
      debugPrint('Error updating post $id: $e');
    }
    return null;
  }

  Future<Post?> partialUpdatePost(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/posts/$id/', data);
      if (response.statusCode == 200) {
        final updatedPost = Post.fromJson(jsonDecode(response.body));
        final index = _posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
        return updatedPost;
      }
    } catch (e) {
      debugPrint('Error partial updating post $id: $e');
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
