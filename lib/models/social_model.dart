class ConnectionRequest {
  final String id;
  final String sender;
  final String senderName;
  final String receiver;
  final String receiverName;
  final String status;
  final DateTime createdAt;

  ConnectionRequest({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.receiver,
    required this.receiverName,
    required this.status,
    required this.createdAt,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id']?.toString() ?? '',
      sender: json['sender'] is Map
          ? (json['sender']['id']?.toString() ?? '')
          : (json['sender']?.toString() ?? json['sender_id']?.toString() ?? ''),
      senderName:
          json['sender_name'] ??
          (json['sender'] is Map ? (json['sender']['username'] ?? '') : ''),
      receiver: json['receiver'] is Map
          ? (json['receiver']['id']?.toString() ?? '')
          : (json['receiver']?.toString() ??
                json['receiver_id']?.toString() ??
                ''),
      receiverName:
          json['receiver_name'] ??
          (json['receiver'] is Map ? (json['receiver']['username'] ?? '') : ''),
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null
          ? (json['created_at'] is DateTime
                ? json['created_at']
                : DateTime.parse(json['created_at'].toString()))
          : DateTime.now(),
    );
  }
}

class Invitation {
  final String id;
  final String project;
  final String projectName;
  final String senderName;
  final String receiver;
  final String status;
  final DateTime sentAt;

  Invitation({
    required this.id,
    required this.project,
    required this.projectName,
    required this.senderName,
    required this.receiver,
    required this.status,
    required this.sentAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id']?.toString() ?? '',
      project: json['project'] is Map
          ? (json['project']['id']?.toString() ?? '')
          : (json['project']?.toString() ??
                json['project_id']?.toString() ??
                ''),
      projectName:
          json['project_name'] ??
          (json['project'] is Map
              ? (json['project']?['project_name'] ?? '')
              : ''),
      senderName: json['sender_name'] ?? '',
      receiver: json['receiver'] is Map
          ? (json['receiver']['id']?.toString() ?? '')
          : (json['receiver']?.toString() ??
                json['receiver_id']?.toString() ??
                ''),
      status: json['status'] ?? 'PENDING',
      sentAt: json['sent_at'] != null
          ? (json['sent_at'] is DateTime
                ? json['sent_at']
                : DateTime.parse(json['sent_at'].toString()))
          : (json['created_at'] != null
                ? (json['created_at'] is DateTime
                      ? json['created_at']
                      : DateTime.parse(json['created_at'].toString()))
                : DateTime.now()),
    );
  }
}
