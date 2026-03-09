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
      id: json['id'] ?? 0,
      sender: json['sender'] is int
          ? json['sender']
          : (json['sender']?['id'] ?? 0),
      senderName: json['sender_name'] ?? (json['sender']?['username'] ?? ''),
      receiver: json['receiver'] is int
          ? json['receiver']
          : (json['receiver']?['id'] ?? 0),
      receiverName:
          json['receiver_name'] ?? (json['receiver']?['username'] ?? ''),
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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
      id: json['id'] ?? 0,
      project: json['project'] is int
          ? json['project']
          : (json['project']?['id'] ?? 0),
      projectName:
          json['project_name'] ?? (json['project']?['project_name'] ?? ''),
      senderName: json['sender_name'] ?? '',
      receiver: json['receiver'] is int
          ? json['receiver']
          : (json['receiver']?['id'] ?? 0),
      status: json['status'] ?? 'PENDING',
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : DateTime.now()),
    );
  }
}
