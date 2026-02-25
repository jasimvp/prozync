import '../core/constants.dart';

class Post {
  final int id;
  final int user;
  final String username;
  final int? project;
  final String? image;
  final String content;
  final int likeCount;
  final int commentCount;
  final bool isSaved;
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
    this.isSaved = false,
    required this.createdAt,
  });

  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image!;
    String path = image!;
    if (path.startsWith('/')) path = path.substring(1);
    return '${AppConstants.baseUrl}/$path';
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      username: json['username'] ?? 'User',
      project: json['project'],
      image: json['image'],
      content: json['content'] ?? '',
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isSaved: json['is_saved'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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
