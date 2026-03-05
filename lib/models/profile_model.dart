import '../core/constants.dart';

class Profile {
  final int id;
  final int user;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String bio;
  final String profession;
  final String? profilePic;
  final String followerCount;
  final String repoCount;
  final String connectionStatus;

  Profile({
    required this.id,
    required this.user,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.bio,
    required this.profession,
    this.profilePic,
    required this.followerCount,
    required this.repoCount,
    required this.connectionStatus,
  });

  String get fullProfilePic {
    if (profilePic == null || profilePic!.isEmpty) {
      return 'https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=003366&color=fff';
    }

    String imageUrl = profilePic!;

    if (imageUrl.contains('127.0.0.1:8000') || imageUrl.contains('localhost:8000')) {
      imageUrl = imageUrl.replaceAll(RegExp(r'http://(127\.0\.0\.1|localhost):8000/?'), '');
      if (imageUrl.startsWith('/')) imageUrl = imageUrl.substring(1);
      return '${AppConstants.baseUrl}/$imageUrl';
    }

    if (imageUrl.startsWith('http')) return imageUrl;
    if (imageUrl.startsWith('/')) imageUrl = imageUrl.substring(1);
    return '${AppConstants.baseUrl}/$imageUrl';
  }
  factory Profile.fromJson(Map<String, dynamic> json) {
    String status = (json['connection_status'] ?? '').toString().toLowerCase();
    
    // If status is 'followed' or backend provided is_following boolean, treat as 'following'
    if (status == 'followed' || (status.isEmpty && json['is_following'] == true)) {
      status = 'following';
    }

    final rawUsername = json['username'] ?? json['user_name'] ?? '';
    final userId = json['user'] is int 
        ? json['user'] 
        : (json['user'] is Map ? (json['user']['id'] ?? 0) : 0);

    return Profile(
      id: json['id'] ?? 0,
      user: userId,
      username: rawUsername.toString().isNotEmpty ? rawUsername.toString() : 'Unknown',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      profession: json['profession'] ?? '',
      profilePic: json['profile_pic'],
      followerCount: (json['follower_count'] ?? 0).toString(),
      repoCount: (json['repo_count'] ?? 0).toString(),
      connectionStatus: status,
    );
  }

  Profile copyWith({
    int? id,
    int? user,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    String? bio,
    String? profession,
    String? profilePic,
    String? followerCount,
    String? repoCount,
    String? connectionStatus,
  }) {
    return Profile(
      id: id ?? this.id,
      user: user ?? this.user,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profession: profession ?? this.profession,
      profilePic: profilePic ?? this.profilePic,
      followerCount: followerCount ?? this.followerCount,
      repoCount: repoCount ?? this.repoCount,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'bio': bio,
      'profession': profession,
    };
  }
}
