import '../core/constants.dart';

class Post {
  final String id;
  final String user;
  final String username;
  final String fullName;
  final String? project;
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
    String? id,
    String? user,
    String? username,
    String? fullName,
    String? project,
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
    final rawUsername =
        json['username'] ?? json['user_name'] ?? json['author_username'] ?? '';
    final rawFullName =
        json['full_name'] ??
        json['author_name'] ??
        json['user_full_name'] ??
        '';
    final displayUsername = rawUsername.toString().isNotEmpty
        ? rawUsername.toString()
        : rawFullName.toString();

    return Post(
      id: json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      username: displayUsername.isNotEmpty ? displayUsername : 'Unknown',
      fullName: rawFullName.toString(),
      project: json['project']?.toString(),
      image: json['image']?.toString(),
      content: json['content'] ?? '',
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isSaved: json['is_saved'] ?? false,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] != null
          ? (json['created_at'] is String
                ? DateTime.parse(json['created_at'])
                : (json['created_at'] as dynamic).toDate())
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
