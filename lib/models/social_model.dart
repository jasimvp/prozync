class ConnectionRequest {
  final int id;
  final int sender;
  final String senderName;
  final int receiver;
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
      id: json['id'],
      sender: json['sender'],
      senderName: json['sender_name'] ?? '',
      receiver: json['receiver'],
      receiverName: json['receiver_name'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Invitation {
  final int id;
  final int project;
  final String projectName;
  final String senderName;
  final int receiver;
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
      id: json['id'],
      project: json['project'],
      projectName: json['project_name'] ?? '',
      senderName: json['sender_name'] ?? '',
      receiver: json['receiver'],
      status: json['status'] ?? 'PENDING',
      sentAt: DateTime.parse(json['sent_at']),
    );
  }
}
