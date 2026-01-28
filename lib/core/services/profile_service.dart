import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/profile_model.dart';
import 'api_service.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ApiService _apiService = ApiService();
  Profile? _myProfile;
  List<Profile> _profiles = [];
  bool _isLoading = false;

  Profile? get myProfile => _myProfile;
  List<Profile> get profiles => _profiles;
  bool get isLoading => _isLoading;

  Future<void> fetchProfiles({String? search}) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final endpoint = search != null ? '/profiles/?search=$search' : '/profiles/';
      final response = await _apiService.get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _profiles = data.map((json) => Profile.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchMyProfile() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/profiles/me/');
      if (response.statusCode == 200) {
        _myProfile = Profile.fromJson(jsonDecode(response.body));
        return true;
      } else if (response.statusCode == 401) {
        // Token is invalid or expired
        await _apiService.clearToken();
        _myProfile = null;
      } else {
        debugPrint('Profile fetch failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching my profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<Profile?> fetchProfileById(int id) async {
    try {
      final response = await _apiService.get('/profiles/$id/');
      if (response.statusCode == 200) {
        return Profile.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
    return null;
  }

  Future<bool> updateProfile(Map<String, dynamic> data, {http.MultipartFile? profilePic}) async {
    try {
      http.Response response;
      
      if (profilePic != null) {
        // Convert map values to strings for multipart fields
        final Map<String, String> fields = data.map((key, value) => MapEntry(key, value.toString()));
        response = await _apiService.patchMultipart('/profiles/me/', fields, files: profilePic != null ? [profilePic] : null);
      } else {
        response = await _apiService.patch('/profiles/me/', data);
      }

      if (response.statusCode == 200) {
        _myProfile = Profile.fromJson(jsonDecode(response.body));
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
    return false;
  }

  Future<bool> followProfile(int id) async {
    try {
      final response = await _apiService.post('/profiles/$id/follow/', {});
      if (response.statusCode == 200) {
        // Optionially refresh my profile or the follow list
        return true;
      }
    } catch (e) {
      debugPrint('Error following profile: $e');
    }
    return false;
  }
}
