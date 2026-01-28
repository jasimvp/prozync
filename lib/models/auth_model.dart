class AuthToken {
  final String token;

  AuthToken({required this.token});

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'],
    );
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, String> toBody() {
    return {
      'username': username,
      'password': password,
    };
  }
}
