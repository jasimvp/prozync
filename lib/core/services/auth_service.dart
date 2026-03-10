import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../models/auth_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    // Mock successful login
    await Future.delayed(const Duration(seconds: 1));
    await _apiService.saveToken('mock_token_12345');
    return {
      'success': true,
      'token': AuthToken(token: 'mock_token_12345'),
    };
  }

  Future<Map<String, dynamic>> verifySignupOtp(String email, String otp) async {
    // Mock OTP verification
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true};
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    // Mock signup
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true};
  }

  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> resetPassword(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> logout() async {
    await _apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
