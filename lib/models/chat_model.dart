class Message {
  final int id;
  final int senderId;
  final String senderName;
  final int? receiverId;
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

  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    return Message(
      id: json['id'],
      senderId: json['sender'],
      senderName: json['sender_name'] ?? '',
      receiverId: json['receiver'],
      receiverName: json['receiver_name'],
      text: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['timestamp']),
      isMe: json['sender'] == currentUserId,
    );
  }
}

class ChatPreview {
  final int id;
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
    return ChatPreview(
      id: json['id'],
      otherUserName: json['other_user_name'] ?? 'User',
      otherUserImage: json['other_user_image'] ?? 'https://ui-avatars.com/api/?name=User',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: DateTime.parse(json['last_message_time'] ?? DateTime.now().toIso8601String()),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
