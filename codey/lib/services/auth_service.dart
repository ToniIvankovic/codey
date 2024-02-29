import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _loginEndpoint = '${dotenv.env["API_BASE"]}/user/login';
  final String _registerEndpoint = '${dotenv.env["API_BASE"]}/user/register';
  String? _token;

  Future<String?> get token async {
    _token ??= await _getToken();
    try {
      _checkTokenExpired();
    } catch (e) {
      await _clearToken();
      return Future(() => null);
    }
    return Future.value(_token);
  }

  AuthService() {
    _getToken();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  Future<void> _clearToken() async {
    _token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }

  Future<void> _setToken(token) async {
    _token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  DateTime? _getTokenExpiration() {
    if (_token != null) {
      final Map<String, dynamic> decodedToken = Jwt.parseJwt(_token!);
      if (decodedToken.containsKey('exp')) {
        final int expirationTimestamp = decodedToken['exp'];
        return DateTime.fromMillisecondsSinceEpoch(expirationTimestamp * 1000);
      }
    }
    return null;
  }

  void _checkTokenExpired() {
    var expiration = _getTokenExpiration();
    if (expiration != null && expiration.isBefore(DateTime.now())) {
      throw UnauthenticatedException('Token expired');
    }
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
      await _setToken(token);

      return token;
    } else {
      throw Exception('Incorrect username or password');
    }
  }

  Future<void> logout() async {
    _clearToken();
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(_registerEndpoint),
      body: json.encode({'email': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      var errorMessage = json.decode(response.body);
      throw Exception('Failed to register. Reason: ${errorMessage["message"]}');
    }
  }
}
