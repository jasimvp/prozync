import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching notifications: $e');
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(id)
          .update({'read': true});

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          sender: _notifications[index].sender,
          senderName: _notifications[index].senderName,
          receiver: _notifications[index].receiver,
          status: _notifications[index].status,
          createdAt: _notifications[index].createdAt,
          message: _notifications[index].message,
          isRead: true,
          post: _notifications[index].post,
          project: _notifications[index].project,
          senderProfilePic: _notifications[index].senderProfilePic,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> sendNotification({
    required String receiverId,
    required String status,
    String? postId,
    String? projectId,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .add({
            'type': status,
            'from_uid': user.uid,
            'from_name': user.displayName ?? 'Someone',
            'message': message,
            'post_id': postId,
            'project_id': projectId,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  void clear() {
    _notifications = [];
    _isLoading = false;
    notifyListeners();
  }
}
