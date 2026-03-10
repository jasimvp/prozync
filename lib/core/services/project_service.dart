import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prozync/models/project_model.dart';
import 'package:prozync/models/social_model.dart';

class ProjectService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = [];
  List<Project> _myRepos = [];
  List<Project> _pinnedProjects = [];
  List<Project> _savedProjects = [];
  List<Invitation> _invitations = [];

  bool _isLoading = false;
  bool _isMyReposLoading = false;
  bool _isPinnedLoading = false;
  bool _isSavedLoading = false;

  List<Project> get projects => _projects;
  List<Project> get myRepos => _myRepos;
  List<Project> get pinnedProjects => _pinnedProjects;
  List<Project> get savedProjects => _savedProjects;
  List<Invitation> get invitations => _invitations;

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
      _projects = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Project.fromJson({...data, 'id': doc.id});
      }).toList();
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
      _myRepos = snapshot.docs.map((doc) {
        final data = doc.data();
        return Project.fromJson({...data, 'id': doc.id});
      }).toList();
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

      _pinnedProjects = projectsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Project.fromJson({...data, 'id': doc.id});
      }).toList();
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

      _savedProjects = projectsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Project.fromJson({...data, 'id': doc.id});
      }).toList();
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
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Project.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error fetching user projects: $e');
      return [];
    }
  }

  Future<void> fetchInvitations() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('invitations')
          .where('receiver_id', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      _invitations = snapshot.docs.map((doc) {
        return Invitation.fromJson({...doc.data(), 'id': doc.id});
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching invitations: $e');
      notifyListeners();
    }
  }

  Future<bool> respondToInvitation(String invitationId, String action) async {
    try {
      final inviteRef = _firestore.collection('invitations').doc(invitationId);
      final inviteDoc = await inviteRef.get();
      if (!inviteDoc.exists) return false;

      final inviteData = inviteDoc.data()!;
      final projectId = inviteData['project_id'];
      final receiverId = inviteData['receiver_id'];
      final receiverName = _auth.currentUser?.displayName ?? 'User';

      if (action == 'accepted') {
        // Add to project collaborators
        final projectRef = _firestore.collection('projects').doc(projectId);
        final projectDoc = await projectRef.get();
        if (projectDoc.exists) {
          final List<dynamic> collabs = List.from(
            projectDoc.data()?['collaborators'] ?? [],
          );
          collabs.add({
            'uid': receiverId,
            'username': receiverName,
            'profile_pic': _auth.currentUser?.photoURL,
          });

          await projectRef.update({
            'collaborators': collabs,
            'collaborator_count': collabs.length,
          });

          // Send Notification to sender that their invitation was accepted
          final senderId = inviteData['sender_id'];
          if (senderId != null) {
            await _firestore
                .collection('users')
                .doc(senderId)
                .collection('notifications')
                .add({
                  'type': 'collab_accept',
                  'from_uid': _auth.currentUser?.uid,
                  'from_name': receiverName,
                  'project_id': projectId,
                  'project_name':
                      projectDoc.data()?['project_name'] ?? 'Project',
                  'message': '$receiverName accepted your invitation to collab',
                  'timestamp': FieldValue.serverTimestamp(),
                  'read': false,
                });
          }
        }
        await inviteRef.update({'status': 'accepted'});
      } else {
        await inviteRef.update({'status': 'rejected'});
      }

      // Refresh invitations list after responding
      await fetchInvitations();
      return true;
    } catch (e) {
      debugPrint('Error responding to invitation: $e');
      return false;
    }
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
        'owner': user.uid,
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
      bool pinnedStatus = false;
      if (doc.exists) {
        await ref.delete();
        pinnedStatus = false;
      } else {
        await ref.set({
          'id': projectId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        pinnedStatus = true;
      }

      // Also update project document if the user is the owner
      final projectDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();
      if (projectDoc.exists) {
        final data = projectDoc.data()!;
        if ((data['owner'] ?? data['owner_id']) == user.uid) {
          await _firestore.collection('projects').doc(projectId).update({
            'is_pinned': pinnedStatus,
          });
        }
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
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final projectDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();
      if (!projectDoc.exists) return false;

      final projectData = projectDoc.data()!;
      final ownerId = projectData['owner_id'] ?? projectData['owner'] ?? '';
      final projectName = projectData['project_name'] ?? 'Project';

      if (ownerId == user.uid)
        return false; // Cannot be interested in own project

      final interestRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('interested_users')
          .doc(user.uid);

      final interestDoc = await interestRef.get();

      if (interestDoc.exists) {
        await interestRef.delete();
        await _firestore.collection('projects').doc(projectId).update({
          'interested_count': FieldValue.increment(-1),
        });
        return true;
      } else {
        await interestRef.set({
          'uid': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'username': user.displayName ?? 'Interested User',
        });

        await _firestore.collection('projects').doc(projectId).update({
          'interested_count': FieldValue.increment(1),
        });

        // Send Notification to project owner
        await _firestore
            .collection('users')
            .doc(ownerId)
            .collection('notifications')
            .add({
              'type': 'interest',
              'from_uid': user.uid,
              'from_name': user.displayName ?? 'Someone',
              'project_id': projectId,
              'project_name': projectName,
              'message':
                  '${user.displayName ?? 'Someone'} is interested to collab with $projectName',
              'timestamp': FieldValue.serverTimestamp(),
              'read': false,
            });

        return true;
      }
    } catch (e) {
      debugPrint('Error toggling interest: $e');
      return false;
    }
  }

  Future<bool> inviteUser(String projectId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final projectDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();
      if (!projectDoc.exists) return false;

      final projectData = projectDoc.data()!;
      final projectName = projectData['project_name'] ?? 'Project';

      // Check if already a collaborator
      final List<dynamic> collaborators = projectData['collaborators'] ?? [];
      if (collaborators.any((c) => (c is Map ? c['uid'] : c) == userId)) {
        return false;
      }

      // Add to Invitations collection
      await _firestore.collection('invitations').add({
        'project_id': projectId,
        'project_name': projectName,
        'sender_id': user.uid,
        'sender_name': user.displayName ?? 'Owner',
        'receiver_id': userId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Send Notification to receiver
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'type': 'invitation',
            'from_uid': user.uid,
            'from_name': user.displayName ?? 'Someone',
            'project_id': projectId,
            'project_name': projectName,
            'message':
                '${user.displayName ?? 'Someone'} invited you to collab on $projectName',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });

      return true;
    } catch (e) {
      debugPrint('Error inviting user: $e');
      return false;
    }
  }

  Future<void> fetchUserPinnedProjects(String uid) async {
    try {
      _isPinnedLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('projects')
          .where('owner', isEqualTo: uid)
          .where('is_pinned', isEqualTo: true)
          .get();

      _pinnedProjects = snapshot.docs.map((doc) {
        final data = doc.data();
        return Project.fromJson({...data, 'id': doc.id});
      }).toList();

      _isPinnedLoading = false;
      notifyListeners();
    } catch (e) {
      _isPinnedLoading = false;
      debugPrint('Fetch User Pinned Projects Error: $e');
      notifyListeners();
    }
  }

  Project getProjectById(String id, Project fallback) {
    return _projects.firstWhere((p) => p.id == id, orElse: () => fallback);
  }

  Future<Project?> fetchProjectById(String id) async {
    final doc = await _firestore.collection('projects').doc(id).get();
    if (doc.exists) {
      return Project.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
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
