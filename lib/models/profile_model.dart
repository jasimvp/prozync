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
