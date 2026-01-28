import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../models/auth_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
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
      // API expects: username, email, password, full_name
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
          final errorData = jsonDecode(response.body);
          // Handle Django list-style errors or map errors
          if (errorData is Map) {
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorData.values.first.toString();
          } else {
            errorMessage = errorData.toString();
          }
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiService.post('/auth/password-reset/', {'email': email});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Forgot Password Error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(Map<String, dynamic> data) async {
    try {
      // API might expect: email, otp, password (or new_password)
      final response = await _apiService.post('/auth/password-reset-confirm/', {
        'email': data['email'],
        'otp': data['otp'],
        'password': data['new_password'],
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
