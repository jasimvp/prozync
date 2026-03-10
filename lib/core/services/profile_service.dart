import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../models/social_model.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  Profile? _myProfile;
  List<Profile> _profiles = [];
  List<ConnectionRequest> _connections = [];
  bool _isLoading = false;

  Profile? get myProfile => _myProfile;
  List<Profile> get profiles => _profiles;
  List<ConnectionRequest> get connections => _connections;
  bool get isLoading => _isLoading;

  Future<void> fetchProfiles({String? search}) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _profiles = [
      Profile(
        id: '1',
        user: '1',
        username: 'jasim_dev',
        email: 'jasim@example.com',
        fullName: 'Jasim VP',
        phone: '1234567890',
        bio: 'Flutter Developer | UI Enthusiast',
        profession: 'Software Engineer',
        followerCount: '120',
        repoCount: '15',
        connectionStatus: 'following',
      ),
      Profile(
        id: '2',
        user: '2',
        username: 'alice_smith',
        email: 'alice@example.com',
        fullName: 'Alice Smith',
        phone: '0987654321',
        bio: 'Backend Specialist',
        profession: 'Developer',
        followerCount: '450',
        repoCount: '23',
        connectionStatus: 'none',
      ),
    ];

    if (search != null && search.isNotEmpty) {
      _profiles = _profiles
          .where(
            (p) =>
                p.username.toLowerCase().contains(search.toLowerCase()) ||
                p.fullName.toLowerCase().contains(search.toLowerCase()),
          )
          .toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> fetchMyProfile() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _myProfile = Profile(
      id: '1',
      user: '1',
      username: 'jasim_dev',
      email: 'jasim@example.com',
      fullName: 'Jasim VP',
      phone: '1234567890',
      bio: 'Flutter Developer | UI Enthusiast',
      profession: 'Software Engineer',
      followerCount: '120',
      repoCount: '15',
      connectionStatus: 'following',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<Profile?> fetchProfileById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Profile(
      id: id,
      user: id,
      username: 'user_$id',
      email: 'user$id@example.com',
      fullName: 'User $id',
      phone: '1234567890',
      bio: 'Hello from mock user $id',
      profession: 'Developer',
      followerCount: '100',
      repoCount: '5',
      connectionStatus: 'none',
    );
  }

  Future<bool> updateProfile(
    Map<String, dynamic> data, {
    dynamic profilePic,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_myProfile != null) {
      _myProfile = _myProfile!.copyWith(
        fullName: data['full_name']?.toString(),
        phone: data['phone']?.toString(),
        bio: data['bio']?.toString(),
        profession: data['profession']?.toString(),
      );
      notifyListeners();
    }
    return true;
  }

  Future<String?> followProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      final isFollowing = _profiles[index].connectionStatus == 'following';
      _profiles[index] = _profiles[index].copyWith(
        connectionStatus: isFollowing ? 'none' : 'following',
        followerCount:
            (int.parse(_profiles[index].followerCount) + (isFollowing ? -1 : 1))
                .toString(),
      );
      notifyListeners();
      return isFollowing ? 'Unfollowed' : 'Following';
    }
    return 'Success';
  }

  Future<void> fetchConnections() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _connections = [
      ConnectionRequest(
        id: 1,
        sender: 2,
        senderName: 'Alice Smith',
        receiver: 1,
        receiverName: 'Jasim VP',
        status: 'PENDING',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendConnectionRequest(String receiverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> respondToConnection(int id, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _connections.removeWhere((c) => c.id == id);
    notifyListeners();
    return true;
  }

  Future<Profile?> createProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return Profile.fromJson(data);
  }

  Future<Profile?> updateProfileById(
    String id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  Future<Profile?> partialUpdateProfileById(
    String id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  Future<bool> deleteProfileById(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> connectWithProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<List<Profile>> fetchTaggableUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _profiles;
  }

  void clear() {
    _myProfile = null;
    _profiles = [];
    _connections = [];
    _isLoading = false;
    notifyListeners();
  }
}
