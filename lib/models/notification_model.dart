import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String sender;
  final String senderName;
  final String receiver;
  final String status;
  final String? post;
  final String? project;
  final String message;
  final String? senderProfilePic;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.receiver,
    required this.status,
    this.post,
    this.project,
    required this.message,
    this.senderProfilePic,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTime(dynamic timestamp) {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) return DateTime.parse(timestamp);
      return DateTime.now();
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? json['from_uid']?.toString() ?? '',
      senderName: json['sender_name'] ?? json['from_name'] ?? 'Someone',
      receiver: json['receiver']?.toString() ?? '',
      status: json['status'] ?? json['type'] ?? 'INFO',
      post: json['post']?.toString(),
      project: json['project']?.toString(),
      message: json['message'] ?? '',
      senderProfilePic: json['sender_profile_pic'],
      isRead: json['is_read'] ?? json['read'] ?? false,
      createdAt: parseTime(json['created_at'] ?? json['timestamp']),
    );
  }
}
