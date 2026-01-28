import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../models/auth_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Trying documented /auth/login/ which is form-encoded
      final response = await _apiService.post(
        '/auth/login/',
        {'username': username, 'password': password},
        isUrlEncoded: true,
      );

      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(jsonDecode(response.body));
        await _apiService.saveToken(token.token);
        return {'success': true, 'token': token};
      } else {
        // Fallback to /auth/signin/ if /login/ fails or isn't handling JSON
        return await signin(username, password);
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> signin(String username, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/signin/',
        {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(jsonDecode(response.body));
        await _apiService.saveToken(token.token);
        return {'success': true, 'token': token};
      } else {
        String message = 'Invalid credentials';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            message = errorData['detail'] ?? errorData['message'] ?? errorData.values.first.toString();
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/auth/signup/', {
        'username': data['username'],
        'email': data['email'],
        'password': data['password'],
        'full_name': data['full_name'] ?? data['username'],
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        String errorMessage = 'Signup failed';
        try {
          if (response.body.isNotEmpty) {
            final errorData = jsonDecode(response.body);
            if (errorData is Map) {
              errorMessage = errorData['detail'] ?? errorData['message'] ?? errorData.values.first.toString();
            }
          }
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiService.post('/auth/forgot-password/', {'email': email});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Forgot Password Error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/auth/reset-password/', {
        'email': data['email'],
        'otp': data['otp'],
        'new_password': data['new_password'],
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Reset Password Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        // Attempt to notify server, but ignore errors if it fails
        await _apiService.post('/auth/logout/', {});
      }
    } catch (e) {
      debugPrint('Logout error (server side): $e');
    }
    await _apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
