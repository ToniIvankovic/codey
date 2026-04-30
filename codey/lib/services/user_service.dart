import 'dart:async';
import 'dart:convert';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

abstract class UserService {
  Stream<AppUser> get userStream;
  AppUser? get currentUser;
  Stream<void> get courseChanged;
  Future<void> initializeUser();
  void logout();
  void updateUser(AppUser user);
  Future<AppUser> changeUserData({
    required String firstName,
    required String lastName,
    DateTime? dateOfBirth,
    String? leaderboardName,
  });
  Future<AppUser> resetLeaderboardName();
  Future<AppUser> switchCourse(int courseId);
}

class UserService1 implements UserService {
  final Uri _userEndpoint = Uri.parse('${dotenv.env["API_BASE"]}/user');
  final AuthService _authService;
  final http.Client _authenticatedClient;
  late BehaviorSubject<AppUser> _userSubject;
  final PublishSubject<void> _courseChangedSubject = PublishSubject<void>();

  UserService1(this._authService, this._authenticatedClient) {
    initializeUser();
  }

  @override
  Stream<AppUser> get userStream => _userSubject.stream;

  @override
  AppUser? get currentUser =>
      _userSubject.isClosed ? null : _userSubject.valueOrNull;

  @override
  Stream<void> get courseChanged => _courseChangedSubject.stream;

  @override
  void updateUser(AppUser user) {
    if (_userSubject.isClosed) return;
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
    DateTime? dateOfBirth,
    String? leaderboardName,
  }) async {
    final body = <String, String>{
      'firstName': firstName,
      'lastName': lastName,
    };
    if (dateOfBirth != null) {
      body['dateOfBirth'] = dateOfBirth.toIso8601String();
    }
    final trimmedLeaderboardName = leaderboardName?.trim();
    if (trimmedLeaderboardName != null && trimmedLeaderboardName.isNotEmpty) {
      body['leaderboardName'] = trimmedLeaderboardName;
    }

    var response = await _authenticatedClient.put(
      _userEndpoint,
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Failed to change user data');
    }

    var user = AppUser.fromJson(jsonDecode(response.body));
    updateUser(user);
    return user;
  }

  @override
  Future<AppUser> resetLeaderboardName() async {
    var response = await _authenticatedClient.delete(
      Uri.parse('$_userEndpoint/leaderboard-name'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body.isNotEmpty
          ? response.body
          : 'Failed to reset leaderboard name');
    }

    var user = AppUser.fromJson(jsonDecode(response.body));
    updateUser(user);
    return user;
  }

  @override
  Future<AppUser> switchCourse(int courseId) async {
    var response = await _authenticatedClient.put(
      Uri.parse('$_userEndpoint/course'),
      body: json.encode({'courseId': courseId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to switch course');
    }

    _courseChangedSubject.add(null);
    var user = AppUser.fromJson(jsonDecode(response.body));
    updateUser(user);
    return user;
  }
}
