import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  // Mock network call helper
  Future<http.Response> _mockNetworkCall() async {
    return http.Response(jsonEncode({'detail': 'Backend decoupled. Use mock services.'}), 404);
  }

  Future<http.Response> get(String endpoint) async {
    debugPrint('ApiService.get called for $endpoint (BLOCKED)');
    return _mockNetworkCall();
  }

  Future<http.Response> post(String endpoint, dynamic body,
      {bool isUrlEncoded = false}) async {
    debugPrint('ApiService.post called for $endpoint (BLOCKED)');
    return _mockNetworkCall();
  }

  Future<http.Response> put(String endpoint, dynamic body) async {
    debugPrint('ApiService.put called for $endpoint (BLOCKED)');
    return _mockNetworkCall();
  }

  Future<http.Response> patch(String endpoint, dynamic body) async {
    debugPrint('ApiService.patch called for $endpoint (BLOCKED)');
    return _mockNetworkCall();
  }

  Future<http.Response> delete(String endpoint) async {
    debugPrint('ApiService.delete called for $endpoint (BLOCKED)');
    return _mockNetworkCall();
  }

  Future<http.Response> postMultipart(
      String endpoint, Map<String, String> fields,
      {List<http.MultipartFile>? files}) async {
    debugPrint('ApiService.postMultipart called for $endpoint (BLOCKED)');
    return _mockNetworkCall();
  }

  Future<http.Response> patchMultipart(
      String endpoint, Map<String, String> fields,
      {List<http.MultipartFile>? files}) async {
    debugPrint('ApiService.patchMultipart called for $endpoint (BLOCKED)');
    return _mockNetworkCall();
  }
}
