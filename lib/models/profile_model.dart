class Profile {
  final int id;
  final int user;
  final String username;
  final String fullName;
  final String phone;
  final String bio;
  final String profession;
  final String? profilePic;
  final String followerCount;
  final String repoCount;

  Profile({
    required this.id,
    required this.user,
    required this.username,
    required this.fullName,
    required this.phone,
    required this.bio,
    required this.profession,
    this.profilePic,
    required this.followerCount,
    required this.repoCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      user: json['user'],
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      profession: json['profession'] ?? '',
      profilePic: json['profile_pic'],
      followerCount: json['follower_count'].toString(),
      repoCount: json['repo_count'].toString(),
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
