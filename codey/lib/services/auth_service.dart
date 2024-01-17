import 'package:codey/auth/authenticated_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AuthService {
  final String _loginEndpoint = 'http://localhost:5052/auth/login';
  final String _logoutEndpoint = 'http://localhost:5052/auth/logout';
  final String _registerEndpoint = 'http://localhost:5052/auth/register';

  final AuthenticatedClient _authenticatedClient;

  AuthService(this._authenticatedClient);


  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_loginEndpoint),
      body: json.encode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];

      // Store the token on the device
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return token;
    } else {
      throw Exception('Failed to log in.');
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    final response = await _authenticatedClient.post(
      Uri.parse(_logoutEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Remove the token from the device
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } else {
      throw Exception('Failed to log out.');
    }
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
