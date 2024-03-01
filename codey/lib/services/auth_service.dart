import 'package:codey/models/exceptions/authentication_exception.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthService {
  Future<String?> get token;
  Future<void> login(String username, String password);
  Future<void> logout();
  Future<void> register(String username, String password);
}

class AuthService1 implements AuthService {
  final Uri _loginEndpoint = Uri.parse('${dotenv.env["API_BASE"]}/user/login');
  final Uri _registerEndpoint =
      Uri.parse('${dotenv.env["API_BASE"]}/user/register');
  String? _token;

  AuthService1() {
    _getTokenFromStorage();
  }

  @override
  Future<void> login(String username, String password) async {
    final response = await http.post(
      _loginEndpoint,
      body: json.encode({'email': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw AuthenticationException('Incorrect username or password');
    }

    final data = json.decode(response.body);
    final token = data['token'];
    await _setToken(token);
  }

  @override
  Future<void> logout() async {
    _clearToken();
  }

  @override
  Future<void> register(String username, String password) async {
    final response = await http.post(
      _registerEndpoint,
      body: json.encode({'email': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      var errorMessage = json.decode(response.body);
      errorMessage = errorMessage['message'].toString().substring(1, errorMessage['message'].toString().length - 1).split(", ").join("\n");
      throw AuthenticationException(errorMessage);
    }
  }

  @override
  Future<String?> get token async {
    _token ??= await _getTokenFromStorage();
    if (_token == null) {
      return Future(() => null);
    }

    // Token exists, but might be expired
    try {
      _checkTokenExpired();
    } catch (e) {
      await _clearToken();
    }

    return _token;
  }

  Future<String?> _getTokenFromStorage() async {
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

  void _checkTokenExpired() {
    var expiration = _getTokenExpiration();
    if (expiration != null && expiration.isBefore(DateTime.now())) {
      throw UnauthenticatedException('Token expired');
    }
  }

  DateTime? _getTokenExpiration() {
    if (_token == null) {
      return null;
    }

    final Map<String, dynamic> decodedToken = Jwt.parseJwt(_token!);
    if (!decodedToken.containsKey('exp')) {
      return null;
    }

    final int expirationTimestamp = decodedToken['exp'];
    return DateTime.fromMillisecondsSinceEpoch(expirationTimestamp * 1000);
  }
}
