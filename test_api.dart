import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> checkUrl(String url) async {
  try {
    var res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': 'test', 'password': 'test'}),
    );
    print('$url -> ${res.statusCode}');
  } catch (e) {
    print('$url -> Error');
  }
}

void main() async {
  await checkUrl('https://prozync.onrender.com/api/login/');
  await checkUrl('https://prozync.onrender.com/api/user/login/');
  await checkUrl('https://prozync.onrender.com/api/users/login/');
  await checkUrl('https://prozync.onrender.com/api/auth/token/');
  await checkUrl('https://prozync.onrender.com/api/token-auth/');
}
