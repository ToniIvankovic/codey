import 'dart:async';
import 'dart:convert';

import 'package:codey/models/app_user.dart';
import 'package:codey/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class UserService {
  final String _userEndpoint = 'http://localhost:5052/user';
  final AuthService _authService;
  final http.Client _authenticatedClient;
  AppUser? _user;
  String? _token;
  late BehaviorSubject<AppUser?> _userSubject;

  UserService(this._authService, this._authenticatedClient) {
    initializeUser();
  }

  Stream<AppUser?> get userStream => _userSubject.stream;

  set user(AppUser user) {
    _user = user;
    _userSubject.add(_user!);
  }

  void logout() {
    _user = null;
    // _userSubject.add(null);
    _dispose();
  }

  void _dispose() {
    _userSubject.close();
  }

  Future<void> initializeUser() async {
    _userSubject = BehaviorSubject<AppUser?>();
    var token = await _authService.token;
    if (token == null) {
      return;
    }

    var response = await _authenticatedClient.get(
      Uri.parse(_userEndpoint),
    );

    if (response.statusCode == 200) {
      user = AppUser.fromJson(jsonDecode(response.body));
    } else {
      await _authService.logout();
      logout();
    }
  }
}
