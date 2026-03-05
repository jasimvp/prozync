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
    notifyListeners();

    try {
      final response = await _apiService.get('/notifications/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      // Assuming GET to specific ID marks it as read or there's a specific logic
      final response = await _apiService.get('/notifications/$id/');
      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          // Update local state
          fetchNotifications(); // Refresh list
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<bool> sendNotification({
    required int receiver,
    required String message,
    int? projectId,
    int? postId,
  }) async {
    try {
      final body = <String, dynamic>{
        'receiver': receiver,
        'message': message,
      };
      if (projectId != null) body['project'] = projectId;
      if (postId != null) body['post'] = postId;

      final response = await _apiService.post('/notifications/', body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Notification sent to receiver $receiver');
        return true;
      }
      debugPrint('Failed to send notification: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }
}
