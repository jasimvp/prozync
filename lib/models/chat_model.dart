import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String? receiverId;
  final String? receiverName;
  final String text;
  final bool isRead;
  final DateTime createdAt;
  final bool isMe;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.receiverId,
    this.receiverName,
    required this.text,
    required this.isRead,
    required this.createdAt,
    this.isMe = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    DateTime parseTime(dynamic timestamp) {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) return DateTime.parse(timestamp);
      return DateTime.now();
    }

    final sender =
        json['sender']?.toString() ?? json['sender_id']?.toString() ?? '';

    return Message(
      id: json['id']?.toString() ?? '',
      senderId: sender,
      senderName: json['sender_name'] ?? 'User',
      receiverId:
          json['receiver']?.toString() ?? json['receiver_id']?.toString(),
      receiverName: json['receiver_name'],
      text: json['message'] ?? json['text'] ?? '',
      isRead: json['is_read'] ?? json['read'] ?? false,
      createdAt: parseTime(json['timestamp'] ?? json['created_at']),
      isMe: sender == currentUserId,
    );
  }
}

class ChatPreview {
  final String id; // This is usually the other user's ID
  final String otherUserName;
  final String otherUserImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatPreview({
    required this.id,
    required this.otherUserName,
    required this.otherUserImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    DateTime parseTime(dynamic timestamp) {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) return DateTime.parse(timestamp);
      return DateTime.now();
    }

    return ChatPreview(
      id: json['id']?.toString() ?? '',
      otherUserName: json['other_user_name'] ?? 'User',
      otherUserImage:
          json['other_user_image'] ?? 'https://ui-avatars.com/api/?name=User',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: parseTime(
        json['last_message_time'] ?? json['timestamp'],
      ),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
