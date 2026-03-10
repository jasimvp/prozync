class Comment {
  final int id;
  final int user;
  final String username;
  final String? fullName;
  final int post;
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
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      username: json['username'] ?? 'User',
      fullName: json['full_name'],
      post: json['post'] ?? 0,
      content: json['content'] ?? json['comment_text'] ?? json['text'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
