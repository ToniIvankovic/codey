import 'package:codey/models/exceptions/authentication_exception.dart';
import 'package:codey/models/exceptions/invalid_data_exception.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthService {
  Future<String?> get token;
  Future<void> login({
    required String username,
    required String password,
  });
  Future<void> logout();
  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String email,
    required String password,
    required String school,
  });
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
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
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      _loginEndpoint,
      body: json.encode({'email': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw AuthenticationException('Neispravno korisnično ime ili lozinka');
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
  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String email,
    required String password,
    required String school,
  }) async {
    final response = await http.post(
      _registerEndpoint,
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'email': email,
        'password': password,
        'school': school,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      var errorMessage = json.decode(response.body);
      errorMessage = errorMessage['message']
          .toString()
          .substring(1, errorMessage['message'].toString().length - 1)
          .split(", ")
          .join("\n");
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
      return null;
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

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final Uri changePasswordEndpoint =
        Uri.parse('${dotenv.env["API_BASE"]}/user/change-password');
    final response = await http.post(
      changePasswordEndpoint,
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode != 200) {
      var errorMessage = response.body;
      // errorMessage = errorMessage['message']
      //     .toString()
      //     .substring(1, errorMessage['message'].toString().length - 1)
      //     .split(", ")
      //     .join("\n");
      throw InvalidDataException(errorMessage);
    }
  }
}
