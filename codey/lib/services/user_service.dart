import 'dart:async';
import 'dart:convert';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

abstract class UserService {
  Stream<AppUser> get userStream;
  Future<void> initializeUser();
  void logout();
  void updateUser(AppUser user);
  Future<AppUser> changeUserData({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
  });
}

class UserService1 implements UserService {
  final Uri _userEndpoint = Uri.parse('${dotenv.env["API_BASE"]}/user');
  final AuthService _authService;
  final http.Client _authenticatedClient;
  late BehaviorSubject<AppUser> _userSubject;

  UserService1(this._authService, this._authenticatedClient) {
    initializeUser();
  }

  @override
  Stream<AppUser> get userStream => _userSubject.stream;

  @override
  void updateUser(AppUser user) {
    _userSubject.add(user);
  }

  @override
  void logout() {
    _userSubject.close();
  }

  @override
  Future<void> initializeUser() async {
    _userSubject = BehaviorSubject<AppUser>();
    var token = await _authService.token;
    if (token == null) {
      return;
    }

    // Token exists, but might be invalid
    var response = await _authenticatedClient.get(_userEndpoint);
    if (response.statusCode != 200) {
      await _authService.logout();
      logout();
      return;
    }

    var user = AppUser.fromJson(jsonDecode(response.body));
    updateUser(user);
  }

  @override
  Future<AppUser> changeUserData({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
  }) async {
    var response = await _authenticatedClient.put(
      _userEndpoint,
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change user data');
    }

    var user = AppUser.fromJson(jsonDecode(response.body));
    updateUser(user);
    return user;
  }
}
