import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../models/auth_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post('/auth/login/', {
        'username': username,
        'password': password,
      }, isUrlEncoded: true);

      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(jsonDecode(response.body));
        await _apiService.saveToken(token.token);
        return {'success': true, 'token': token};
      } else {
        String message = 'Invalid credentials';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            message =
                errorData['detail'] ??
                errorData['message'] ??
                errorData.values.first.toString();
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> verifySignupOtp(String email, String otp) async {
    try {
      final response = await _apiService.post('/auth/verify-signup-otp/', {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        String message = 'Invalid OTP. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            message = errorData['detail'] ??
                errorData['message'] ??
                errorData['otp'] ??
                errorData.values.first.toString();
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please check your connection.'};
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
              errorMessage =
                  errorData['detail'] ??
                  errorData['message'] ??
                  errorData.values.first.toString();
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
      final response = await _apiService.post('/auth/forgot-password/', {
        'email': email,
      });
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/change-password/', {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Change Password Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    // Backend doesn't have a logout endpoint currently, 
    // so we just clear the token locally.
    await _apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
