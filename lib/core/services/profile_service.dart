import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/profile_model.dart';
import '../../models/social_model.dart';
import 'api_service.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ApiService _apiService = ApiService();
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
        return true;
      }
    } catch (e) {
      debugPrint('Error following profile: $e');
    }
    return false;
  }

  Future<void> fetchConnections() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/connections/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _connections = data.map((json) => ConnectionRequest.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching connections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendConnectionRequest(int receiverId) async {
    try {
      final response = await _apiService.post('/connections/', {'receiver': receiverId});
      if (response.statusCode == 201) {
        fetchConnections();
        return true;
      }
    } catch (e) {
      debugPrint('Error sending connection request: $e');
    }
    return false;
  }

  Future<bool> respondToConnection(int id, String status) async {
    try {
      final response = await _apiService.post('/connections/$id/respond/', {'status': status});
      if (response.statusCode == 200) {
        fetchConnections();
        return true;
      }
    } catch (e) {
      debugPrint('Error responding to connection: $e');
    }
    return false;
  }

  Future<Profile?> createProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/profiles/', data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Profile.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
    return null;
  }

  Future<Profile?> updateProfileById(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/profiles/$id/', data);
      if (response.statusCode == 200) {
        return Profile.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error updating profile $id: $e');
    }
    return null;
  }

  Future<Profile?> partialUpdateProfileById(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/profiles/$id/', data);
      if (response.statusCode == 200) {
        return Profile.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error partial updating profile $id: $e');
    }
    return null;
  }

  Future<bool> deleteProfileById(int id) async {
    try {
      final response = await _apiService.delete('/profiles/$id/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting profile $id: $e');
      return false;
    }
  }

  Future<bool> connectWithProfile(int id) async {
    try {
      final response = await _apiService.post('/profiles/$id/connect/', {});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error connecting with profile $id: $e');
      return false;
    }
  }

  Future<List<Profile>> fetchTaggableUsers() async {
    try {
      final response = await _apiService.get('/profiles/taggable_users/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Profile.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching taggable users: $e');
    }
    return [];
  }

  Future<ConnectionRequest?> fetchConnectionById(int id) async {
    try {
      final response = await _apiService.get('/connections/$id/');
      if (response.statusCode == 200) {
        return ConnectionRequest.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching connection $id: $e');
    }
    return null;
  }

  Future<ConnectionRequest?> updateConnectionById(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/connections/$id/', data);
      if (response.statusCode == 200) {
        return ConnectionRequest.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error updating connection $id: $e');
    }
    return null;
  }

  Future<ConnectionRequest?> partialUpdateConnectionById(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/connections/$id/', data);
      if (response.statusCode == 200) {
        return ConnectionRequest.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error partial updating connection $id: $e');
    }
    return null;
  }

  Future<bool> deleteConnectionById(int id) async {
    try {
      final response = await _apiService.delete('/connections/$id/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting connection $id: $e');
      return false;
    }
  }
}
