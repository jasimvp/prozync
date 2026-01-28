class Message {
  final int id;
  final int senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final bool isMe;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.isMe = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    return Message(
      id: json['id'],
      senderId: json['sender'],
      senderName: json['sender_name'] ?? '',
      text: json['message_text'] ?? json['text'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
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
