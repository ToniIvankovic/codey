import 'package:codey/auth/authenticated_client.dart';
import 'package:codey/models/claim_types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _loginEndpoint = 'http://localhost:5052/user/login';
  final String _registerEndpoint = 'http://localhost:5052/user/register';

  final http.Client _authenticatedClient;

  AuthService(this._authenticatedClient);

  Future<String> getUserEmail() async {
    final token = await AuthenticatedClient.getToken();
    //read claims from token
    final parts = token!.split('.');
    final payload = parts[1];
    final decoded =
        json.decode(utf8.decode(base64.decode(base64.normalize(payload))));
    final email = decoded[ClaimTypes.email];
    return email;
  }

  Future<String> login(String username, String password) async {
    final response = await _authenticatedClient.post(
      Uri.parse(_loginEndpoint),
      body: json.encode({'email': username, 'password': password}),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> register(String username, String password) async {
    final response = await _authenticatedClient.post(
      Uri.parse(_registerEndpoint),
      body: json.encode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {}
  }
}
