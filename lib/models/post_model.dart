import '../core/constants.dart';

class Post {
  final int id;
  final int user;
  final String username;
  final String fullName;
  final int? project;
  final String? image;
  final String content;
  final int likeCount;
  final int commentCount;
  final bool isSaved;
  final bool isLiked;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.user,
    required this.username,
    this.fullName = '',
    this.project,
    this.image,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    this.isSaved = false,
    this.isLiked = false,
    required this.createdAt,
  });

  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image!;
    String path = image!;
    if (path.startsWith('/')) path = path.substring(1);
    return '${AppConstants.baseUrl}/$path';
  }

  Post copyWith({
    int? id,
    int? user,
    String? username,
    String? fullName,
    int? project,
    String? image,
    String? content,
    int? likeCount,
    int? commentCount,
    bool? isSaved,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      project: project ?? this.project,
      image: image ?? this.image,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isSaved: isSaved ?? this.isSaved,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    // Try multiple possible field names for username
    final rawUsername = json['username'] ?? json['user_name'] ?? json['author_username'] ?? '';
    final rawFullName = json['full_name'] ?? json['author_name'] ?? json['user_full_name'] ?? '';
    // Display the full name if username is empty, or vice versa
    final displayUsername = rawUsername.toString().isNotEmpty ? rawUsername.toString() : rawFullName.toString();
    return Post(
      id: json['id'] ?? 0,
      user: json['user'] is int ? json['user'] : (json['user']?['id'] ?? 0),
      username: displayUsername.isNotEmpty ? displayUsername : 'Unknown',
      fullName: rawFullName.toString(),
      project: json['project'],
      image: json['image'],
      content: json['content'] ?? '',
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isSaved: json['is_saved'] ?? false,
      isLiked: json['is_liked'] ?? false,
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
