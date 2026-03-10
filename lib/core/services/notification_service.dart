import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _notifications = [
      NotificationModel(
        id: 1,
        senderName: 'Alice Smith',
        message: 'followed you',
        status: 'FOLLOW',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: 2,
        senderName: 'Bob Builder',
        message: 'liked your post',
        status: 'LIKE',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        senderName: _notifications[index].senderName,
        message: _notifications[index].message,
        status: _notifications[index].status,
        createdAt: _notifications[index].createdAt,
        isRead: true,
      );
      notifyListeners();
    }
  }

  Future<void> sendNotification({
    required int receiverId,
    required String status,
    int? postId,
    int? projectId,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void clear() {
    _notifications = [];
    _isLoading = false;
    notifyListeners();
  }
}
