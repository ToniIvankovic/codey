import 'dart:convert';

import 'package:codey/models/app_user.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/services/auth_service.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String _userEndpoint = 'http://localhost:5052/user';
  final AuthService _authService;
  final http.Client _authenticatedClient;
  AppUser? _user;
  String? _token;

  UserService(this._authService, this._authenticatedClient) {
    initializeUser();
  }

  Future<void> initializeUser() async {
    var token = await _authService.token;
    if (token == null) {
      return;
    }

    var response = await _authenticatedClient.get(
      Uri.parse(_userEndpoint),
    );

    if (response.statusCode == 200) {
      _user = AppUser.fromJson(jsonDecode(response.body));
    } else{
      _authService.logout();
    }
  }

  void updateUser(AppUser user){
    //TODO: no one is notified of this change - notify listeners or use a stream
    _user = user;
  }

  Future<AppUser> get user async {
    var token = await _authService.token;
    if (token == null) {
      throw UnauthenticatedException('No token found');
    } else if (token != _token) {
      _token = token;
      _user = null;
    }

    if (_user == null) {
      await initializeUser();
    }

    //TODO: if user is deleted, and token remained, null is returned here
    return Future.value(_user);
  }

}
