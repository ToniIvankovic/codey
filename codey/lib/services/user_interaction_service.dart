import 'dart:convert';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/class.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class UserInteractionService {
  Future<Class> createClass(String name, List<AppUser> students);
  Future<void> deleteClass(Object id);
  Future<Class> updateClass(Object id, String name, List<AppUser> students);
  Future<List<Class>> getClasses();
  Future<List<AppUser>> queryUsers(String query);
  Future<List<AppUser>> getAllUsers();
}

class UserInteractionServiceImpl implements UserInteractionService {
  final String _baseEndpoint = '${dotenv.env["API_BASE"]}/interaction';
  final http.Client _authenticatedClient;

  UserInteractionServiceImpl(this._authenticatedClient);

  @override
  Future<Class> createClass(String name, List<AppUser> students) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteClass(Object id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Class>> getClasses() {
    throw UnimplementedError();
  }

  @override
  Future<List<AppUser>> queryUsers(String query) async {
    final response = await _authenticatedClient.get(
      Uri.parse('$_baseEndpoint/students?query=$query'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to query users');
    }

    return json
        .decode(response.body)
        .map<AppUser>((user) => AppUser.fromJson(user))
        .toList();
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final response = await _authenticatedClient.get(
      Uri.parse('$_baseEndpoint/students/all'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get all users');
    }

    return json
        .decode(response.body)
        .map<AppUser>((user) => AppUser.fromJson(user))
        .toList();
  }

  @override
  Future<Class> updateClass(Object id, String name, List<AppUser> students) {
    throw UnimplementedError();
  }
}
