class Comment {
  final String id;
  final String user;
  final String username;
  final String? fullName;
  final String post;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.user,
    required this.username,
    this.fullName,
    required this.post,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      username: json['username'] ?? 'User',
      fullName: json['full_name'],
      post: json['post']?.toString() ?? '',
      content: json['content'] ?? json['comment_text'] ?? json['text'] ?? '',
      createdAt: json['created_at'] != null
          ? (json['created_at'] is String
                ? DateTime.parse(json['created_at'])
                : (json['created_at'] as dynamic).toDate())
          : DateTime.now(),
    );
  }
}
