class NotificationModel {
  final int id;
  final int sender;
  final String senderName;
  final int receiver;
  final String status;
  final int? post;
  final int? project;
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
    return NotificationModel(
      id: json['id'],
      sender: json['sender'],
      senderName: json['sender_name'],
      receiver: json['receiver'],
      status: json['status'],
      post: json['post'],
      project: json['project'],
      message: json['message'],
      senderProfilePic: json['sender_profile_pic'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
