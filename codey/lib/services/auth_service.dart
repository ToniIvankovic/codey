import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:codey/models/claim_types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _loginEndpoint = 'http://localhost:5052/user/login';
  final String _registerEndpoint = 'http://localhost:5052/user/register';
  static String? token;

  AuthService();

  static Future<String?> getToken() async {
    return token;
  }

  static Future<void> clearToken() async {
    token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }

  static Future<void> setToken(token) async {
    AuthService.token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<DateTime?> getTokenExpiration() async {
    final token = await getToken();
    if (token != null) {
      final Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      if (decodedToken.containsKey('exp')) {
        final int expirationTimestamp = decodedToken['exp'];
        return DateTime.fromMillisecondsSinceEpoch(expirationTimestamp * 1000);
      }
    }
    return null;
  }

  Future<String> getUserEmail() async {
    final token = await getToken();
    if (token == null) {
      throw UnauthenticatedException('No token found');
    }
    var expiration = await getTokenExpiration();
    if (expiration != null && expiration.isBefore(DateTime.now())) {
      throw UnauthenticatedException('Token expired');
    }
    //read claims from token
    final parts = token!.split('.');
    final payload = parts[1];
    final decoded =
        json.decode(utf8.decode(base64.decode(base64.normalize(payload))));
    final email = decoded[ClaimTypes.email];
    return email;
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_loginEndpoint),
      body: json.encode({'email': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      // Store the token on the device
      await setToken(token);

      return token;
    } else {
      throw Exception('Failed to log in.');
    }
  }


  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(_registerEndpoint),
      body: json.encode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {}
  }
}
