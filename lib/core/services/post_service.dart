import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';

class PostService extends ChangeNotifier {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> fetchPosts({String? search, String? projectId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore
          .collection('posts')
          .orderBy('created_at', descending: true);

      if (projectId != null) {
        query = query.where('project', isEqualTo: projectId);
      }

      final snapshot = await query.get();
      final uid = _auth.currentUser?.uid;

      final List<Post> rawPosts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromJson({...data, 'id': doc.id});
      }).toList();

      if (search != null && search.isNotEmpty) {
        _posts = rawPosts
            .where(
              (p) =>
                  p.content.toLowerCase().contains(search.toLowerCase()) ||
                  p.username.toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
      } else {
        _posts = rawPosts;
      }

      // Fetch liked/saved state for current user
      if (uid != null) {
        for (int i = 0; i < _posts.length; i++) {
          final post = _posts[i];
          final likeDoc = await _firestore
              .collection('posts')
              .doc(post.id)
              .collection('likes')
              .doc(uid)
              .get();
          final saveDoc = await _firestore
              .collection('users')
              .doc(uid)
              .collection('saved_posts')
              .doc(post.id)
              .get();
          _posts[i] = post.copyWith(
            isLiked: likeDoc.exists,
            isSaved: saveDoc.exists,
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching posts: $e');
      notifyListeners();
    }
  }

  Future<void> fetchMyPosts() async {
    if (_auth.currentUser == null) return;
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('posts')
          .where('user', isEqualTo: _auth.currentUser!.uid)
          .orderBy('created_at', descending: true)
          .get();

      _posts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromJson({...data, 'id': doc.id});
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching my posts: $e');
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createPost(
    String content, {
    String? projectId,
    String? imageUrl,
  }) async {
    try {
      if (_auth.currentUser == null) throw 'User not logged in';

      final docRef = _firestore.collection('posts').doc();
      final postData = {
        'id': docRef.id,
        'user': _auth.currentUser!.uid,
        'username': _auth.currentUser!.displayName ?? 'Anonymous',
        'content': content,
        'project': projectId,
        'image': imageUrl,
        'like_count': 0,
        'comment_count': 0,
        'created_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(postData);
      final newPost = Post.fromJson({
        ...postData,
        'created_at': DateTime.now().toIso8601String(),
      });
      _posts.insert(0, newPost);
      notifyListeners();
      return {'success': true, 'post': newPost};
    } catch (e) {
      debugPrint('Error creating post: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> likePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final likeRef = postRef.collection('likes').doc(user.uid);
      final doc = await likeRef.get();

      if (doc.exists) {
        // Unlike
        await likeRef.delete();
        await postRef.update({'like_count': FieldValue.increment(-1)});

        final idx = _posts.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          _posts[idx] = _posts[idx].copyWith(
            likeCount: _posts[idx].likeCount - 1,
            isLiked: false,
          );
          notifyListeners();
        }
      } else {
        // Like
        await likeRef.set({
          'uid': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        await postRef.update({'like_count': FieldValue.increment(1)});

        final idx = _posts.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          _posts[idx] = _posts[idx].copyWith(
            likeCount: _posts[idx].likeCount + 1,
            isLiked: true,
          );
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error liking post: $e');
      return false;
    }
  }

  Future<bool> toggleSavePost(String postId) async {
    if (_auth.currentUser == null) return false;
    try {
      final userRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('saved_posts')
          .doc(postId);
      final doc = await userRef.get();

      if (doc.exists) {
        await userRef.delete();
      } else {
        await userRef.set({
          'post_id': postId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(isSaved: !doc.exists);
        if (_posts[idx].isSaved) {
          if (!_savedPosts.any((p) => p.id == postId)) {
            _savedPosts.insert(0, _posts[idx]);
          }
        } else {
          _savedPosts.removeWhere((p) => p.id == postId);
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error toggling save post: $e');
      return false;
    }
  }

  Future<void> fetchSavedPosts() async {
    if (_auth.currentUser == null) return;
    try {
      _isSavedLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('saved_posts')
          .get();
      final postIds = snapshot.docs.map((doc) => doc.id).toList();

      if (postIds.isEmpty) {
        _savedPosts = [];
      } else {
        final postsSnapshot = await _firestore
            .collection('posts')
            .where(FieldPath.documentId, whereIn: postIds)
            .get();
        _savedPosts = postsSnapshot.docs
            .map(
              (doc) => Post.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }),
            )
            .toList();
      }

      _isSavedLoading = false;
      notifyListeners();
    } catch (e) {
      _isSavedLoading = false;
      debugPrint('Error fetching saved posts: $e');
      notifyListeners();
    }
  }

  Future<List<Comment>> fetchComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('created_at', descending: true)
          .get();
      final comments = snapshot.docs
          .map(
            (doc) => Comment.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
      _comments = comments;
      notifyListeners();
      return comments;
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return [];
    }
  }

  Future<Comment?> addComment(String postId, String content) async {
    try {
      if (_auth.currentUser == null) return null;

      final postRef = _firestore.collection('posts').doc(postId);
      final commentRef = postRef.collection('comments').doc();

      final commentData = {
        'id': commentRef.id,
        'user': _auth.currentUser!.uid,
        'username': _auth.currentUser!.displayName ?? 'Anonymous',
        'content': content,
        'post': postId,
        'created_at': FieldValue.serverTimestamp(),
      };

      await commentRef.set(commentData);
      await postRef.update({'comment_count': FieldValue.increment(1)});

      final newComment = Comment.fromJson({
        ...commentData,
        'created_at': DateTime.now().toIso8601String(),
      });
      _comments.insert(0, newComment);

      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(
          commentCount: _posts[idx].commentCount + 1,
        );
      }

      notifyListeners();
      return newComment;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return null;
    }
  }

  Future<Post?> fetchPostById(String id) async {
    try {
      final doc = await _firestore.collection('posts').doc(id).get();
      if (doc.exists) {
        return Post.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
    } catch (e) {
      debugPrint('Error fetching post by id: $e');
    }
    return null;
  }

  Future<bool> deletePost(String id) async {
    try {
      await _firestore.collection('posts').doc(id).delete();
      _posts.removeWhere((p) => p.id == id);
      _savedPosts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    }
  }

  Future<bool> updatePost(String id, String content) async {
    try {
      await _firestore.collection('posts').doc(id).update({'content': content});

      final idx = _posts.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(content: content);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating post: $e');
      return false;
    }
  }

  void clear() {
    _posts = [];
    _savedPosts = [];
    _comments = [];
    _isLoading = false;
    notifyListeners();
  }
}
