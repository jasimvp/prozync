import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
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
    notifyListeners();

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

  Future<Post?> createPost(String content, {int? projectId, http.MultipartFile? imageFile}) async {
    try {
      final fields = {
        'content': content,
        if (projectId != null) 'project': projectId.toString(),
      };
      
      final response = await _apiService.postMultipart('/posts/', fields, file: imageFile);
      
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
    try {
      final response = await _apiService.post('/posts/$id/like/', {});
      if (response.statusCode == 200) {
        final updatedPost = Post.fromJson(jsonDecode(response.body));
        final index = _posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }
}
