import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
      // Backend uses DRF-style token auth: "Token <key>"
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('${AppConstants.apiBase}$endpoint');
    return await http
        .get(url, headers: _getHeaders(token))
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> post(
    String endpoint,
    dynamic body, {
    bool isUrlEncoded = false,
  }) async {
    final token = await getToken();
    final url = Uri.parse('${AppConstants.apiBase}$endpoint');

    if (isUrlEncoded) {
      final bodyMap = Map<String, String>.from(body);
      final encodedBody = bodyMap.entries
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

  // The _sendMultipart method is kept as it is a private helper,
  // but its public callers (postMultipart, patchMultipart) are now mocked.
  Future<http.Response> _sendMultipart(
    String method,
    String endpoint,
    Map<String, String> fields, {
    List<http.MultipartFile>? files,
  }) async {
    final token = await getToken();
    final url = Uri.parse('${AppConstants.apiBase}$endpoint');
    final request = http.MultipartRequest(method, url);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    });

    request.fields.addAll(fields);
    if (files != null) {
      request.files.addAll(files);
    }

    print('MULTIPART $method Request: $url');
    print('MULTIPART Fields: $fields');
    if (files != null) {
      for (var file in files) {
        print(
          'MULTIPART File: ${file.field} - ${file.filename} (${file.length} bytes)',
        );
      }
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 300),
    );
    final response = await http.Response.fromStream(streamedResponse);

    print('MULTIPART Response Status: ${response.statusCode}');
    print('MULTIPART Response Body: ${response.body}');
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('${AppConstants.apiBase}$endpoint');
    return await http
        .delete(url, headers: _getHeaders(token))
        .timeout(const Duration(seconds: 60));
  }
}
