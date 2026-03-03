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
    return Profile(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      profession: json['profession'] ?? '',
      profilePic: json['profile_pic'],
      followerCount: (json['follower_count'] ?? 0).toString(),
      repoCount: (json['repo_count'] ?? 0).toString(),
      connectionStatus: json['connection_status'] ?? '',
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
