import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import 'api_service.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();
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
        sender: 2,
        senderName: 'Alice Smith',
        receiver: 1,
        status: 'LIKE',
        post: 1,
        message: 'Alice Smith liked your post',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      NotificationModel(
        id: 2,
        sender: 3,
        senderName: 'Bob Builder',
        receiver: 1,
        status: 'FOLLOW',
        message: 'Bob Builder started following you',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        sender: _notifications[index].sender,
        senderName: _notifications[index].senderName,
        receiver: _notifications[index].receiver,
        status: _notifications[index].status,
        post: _notifications[index].post,
        project: _notifications[index].project,
        message: _notifications[index].message,
        senderProfilePic: _notifications[index].senderProfilePic,
        isRead: true,
        createdAt: _notifications[index].createdAt,
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
    // Mock sending notification
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void clear() {
    _notifications = [];
    _isLoading = false;
    notifyListeners();
  }
}
