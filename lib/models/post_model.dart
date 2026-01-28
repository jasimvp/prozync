class Post {
  final int id;
  final int user;
  final String username;
  final int? project;
  final String? image;
  final String content;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.user,
    required this.username,
    this.project,
    this.image,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      user: json['user'],
      username: json['username'],
      project: json['project'],
      image: json['image'],
      content: json['content'],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'project': project,
      'image': image,
      'content': content,
    };
  }
}
