import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prozync/models/project_model.dart';

class ProjectService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = [];
  List<Project> _myRepos = [];
  List<Project> _pinnedProjects = [];
  List<Project> _savedProjects = [];
  List<dynamic> _invitations = [];

  bool _isLoading = false;
  bool _isMyReposLoading = false;
  bool _isPinnedLoading = false;
  bool _isSavedLoading = false;

  List<Project> get projects => _projects;
  List<Project> get myRepos => _myRepos;
  List<Project> get pinnedProjects => _pinnedProjects;
  List<Project> get savedProjects => _savedProjects;
  List<dynamic> get invitations => _invitations;

  bool get isLoading => _isLoading;
  bool get isMyReposLoading => _isMyReposLoading;
  bool get isPinnedLoading => _isPinnedLoading;
  bool get isSavedLoading => _isSavedLoading;

  Future<void> fetchProjects({String? search}) async {
    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore.collection('projects');
      if (search != null && search.isNotEmpty) {
        query = query
            .where('project_name', isGreaterThanOrEqualTo: search)
            .where('project_name', isLessThanOrEqualTo: '$search\uf8ff');
      }
      final snapshot = await query.get();
      _projects = snapshot.docs
          .map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Fetch Projects Error: $e');
      notifyListeners();
    }
  }

  Future<void> fetchMyRepos() async {
    if (_auth.currentUser == null) return;
    try {
      _isMyReposLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('projects')
          .where('owner_id', isEqualTo: _auth.currentUser!.uid)
          .get();
      _myRepos = snapshot.docs
          .map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      _isMyReposLoading = false;
      notifyListeners();
    } catch (e) {
      _isMyReposLoading = false;
      debugPrint('Fetch My Repos Error: $e');
      notifyListeners();
    }
  }

  Future<void> fetchPinnedProjects() async {
    if (_auth.currentUser == null) return;
    try {
      _isPinnedLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('pinned_projects')
          .get();

      final projectIds = snapshot.docs.map((doc) => doc.id).toList();
      if (projectIds.isEmpty) {
        _pinnedProjects = [];
        _isPinnedLoading = false;
        notifyListeners();
        return;
      }

      final projectsSnapshot = await _firestore
          .collection('projects')
          .where('id', whereIn: projectIds)
          .get();

      _pinnedProjects = projectsSnapshot.docs
          .map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      _isPinnedLoading = false;
      notifyListeners();
    } catch (e) {
      _isPinnedLoading = false;
      debugPrint('Fetch Pinned Projects Error: $e');
      notifyListeners();
    }
  }

  Future<void> fetchMySavedProjects() async {
    if (_auth.currentUser == null) return;
    try {
      _isSavedLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('saved_projects')
          .get();

      final projectIds = snapshot.docs.map((doc) => doc.id).toList();
      if (projectIds.isEmpty) {
        _savedProjects = [];
        _isSavedLoading = false;
        notifyListeners();
        return;
      }

      final projectsSnapshot = await _firestore
          .collection('projects')
          .where('id', whereIn: projectIds)
          .get();

      _savedProjects = projectsSnapshot.docs
          .map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      _isSavedLoading = false;
      notifyListeners();
    } catch (e) {
      _isSavedLoading = false;
      debugPrint('Fetch Saved Projects Error: $e');
      notifyListeners();
    }
  }

  Future<List<Project>> getUserProjects(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .where('owner_id', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user projects: $e');
      return [];
    }
  }

  Future<void> fetchInvitations() async {
    _invitations = [];
    notifyListeners();
  }

  Future<bool> respondToInvitation(dynamic id, String action) async {
    return true;
  }

  Future<Map<String, dynamic>> createProject(
    Map<String, dynamic> data, {
    String? coverImageUrl,
    String? zipUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      final docRef = _firestore.collection('projects').doc();
      final projectData = {
        ...data,
        'id': docRef.id,
        'owner_id': user.uid,
        'owner_name': user.displayName ?? 'Anonymous',
        'cover_image': coverImageUrl,
        'project_zip': zipUrl,
        'created_at': DateTime.now().toIso8601String(),
        'likes_count': 0,
        'views_count': 0,
        'language': 'Dart',
      };

      await docRef.set(projectData);
      return {'success': true, 'id': docRef.id};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> togglePin(String projectId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pinned_projects')
          .doc(projectId);
      final doc = await ref.get();
      if (doc.exists) {
        await ref.delete();
      } else {
        await ref.set({
          'id': projectId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      fetchPinnedProjects();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> likeProject(String projectId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final projectRef = _firestore.collection('projects').doc(projectId);
      await projectRef.update({'likes_count': FieldValue.increment(1)});
      fetchProjects();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleSaveProject(String projectId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_projects')
          .doc(projectId);
      final doc = await ref.get();
      if (doc.exists) {
        await ref.delete();
      } else {
        await ref.set({
          'id': projectId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      fetchMySavedProjects();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleInterested(String projectId) async {
    return true;
  }

  Future<bool> inviteUser(String projectId, String userId) async {
    return true;
  }

  Project getProjectById(String id, Project fallback) {
    return _projects.firstWhere((p) => p.id == id, orElse: () => fallback);
  }

  Future<Project?> fetchProjectById(String id) async {
    final doc = await _firestore.collection('projects').doc(id).get();
    if (doc.exists) {
      return Project.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  void clear() {
    _projects = [];
    _myRepos = [];
    _pinnedProjects = [];
    _savedProjects = [];
    _invitations = [];
    notifyListeners();
  }
}
