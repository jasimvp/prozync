import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/profile_model.dart';
import '../../models/social_model.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Profile? _myProfile;
  List<Profile> _profiles = [];
  List<ConnectionRequest> _connections = [];
  bool _isLoading = false;

  Profile? get myProfile => _myProfile;
  List<Profile> get profiles => _profiles;
  List<ConnectionRequest> get connections => _connections;
  bool get isLoading => _isLoading;

  Future<void> fetchProfiles({String? search}) async {
    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore.collection('users');

      if (search != null && search.isNotEmpty) {
        query = query
            .where('username', isGreaterThanOrEqualTo: search)
            .where('username', isLessThanOrEqualTo: '$search\uf8ff');
      }

      final snapshot = await query.limit(20).get();
      _profiles = snapshot.docs
          .map(
            (doc) => Profile.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching profiles: $e');
      notifyListeners();
    }
  }

  Future<bool> fetchMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _myProfile = Profile.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching my profile: $e');
      notifyListeners();
      return false;
    }
  }

  Future<Profile?> fetchProfileById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return Profile.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile $id: $e');
    }
    return null;
  }

  Future<bool> updateProfile(
    Map<String, dynamic> data, {
    dynamic profilePic,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'full_name': data['full_name'],
        'phone': data['phone'],
        'bio': data['bio'],
        'profession': data['profession'],
        if (profilePic != null) 'profile_pic': profilePic,
      });

      await fetchMyProfile();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  Future<String?> followProfile(String targetId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final myRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(targetId);
      final targetRef = _firestore
          .collection('users')
          .doc(targetId)
          .collection('followers')
          .doc(user.uid);

      final doc = await myRef.get();

      if (doc.exists) {
        // Unfollow
        await myRef.delete();
        await targetRef.delete();

        await _firestore.collection('users').doc(user.uid).update({
          'following_count': FieldValue.increment(-1),
        });
        await _firestore.collection('users').doc(targetId).update({
          'follower_count': FieldValue.increment(-1),
        });

        return 'Unfollowed';
      } else {
        // Follow
        await myRef.set({
          'uid': targetId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        await targetRef.set({
          'uid': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('users').doc(user.uid).update({
          'following_count': FieldValue.increment(1),
        });
        await _firestore.collection('users').doc(targetId).update({
          'follower_count': FieldValue.increment(1),
        });

        // Send Notification
        await _firestore
            .collection('users')
            .doc(targetId)
            .collection('notifications')
            .add({
              'type': 'follow',
              'from_uid': user.uid,
              'from_name': user.displayName ?? 'Someone',
              'message':
                  '${user.displayName ?? 'Someone'} started following you',
              'timestamp': FieldValue.serverTimestamp(),
              'read': false,
            });

        return 'Followed';
      }
    } catch (e) {
      debugPrint('Error following profile: $e');
      return null;
    }
  }

  Future<void> fetchConnections() async {
    // Implement if needed for social connections
  }

  Future<bool> sendConnectionRequest(String receiverId) async {
    return true;
  }

  Future<bool> respondToConnection(int id, String status) async {
    return true;
  }

  void clear() {
    _myProfile = null;
    _profiles = [];
    _connections = [];
    _isLoading = false;
    notifyListeners();
  }
}
