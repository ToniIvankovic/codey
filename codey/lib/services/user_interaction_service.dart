import 'dart:convert';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/class.dart';
import 'package:codey/models/exceptions/invalid_data_exception.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class UserInteractionService {
  Future<Class> createClass(String name, List<AppUser> students);
  Future<void> deleteClass(Object id);
  Future<Class> updateClass(Object id, String name, List<AppUser> students);
  Future<List<Class>> getAllClasses();
  Future<List<AppUser>> queryUsers(String query);
  Future<List<AppUser>> getAllUsers();
  Future<List<String>> getAllSchools();
}

class UserInteractionServiceImpl implements UserInteractionService {
  final String _baseEndpoint = '${dotenv.env["API_BASE"]}/interaction';
  final http.Client _authenticatedClient;

  UserInteractionServiceImpl(this._authenticatedClient);

  @override
  Future<Class> createClass(String name, List<AppUser> students) async {
    final response = await _authenticatedClient.post(
      Uri.parse('$_baseEndpoint/classes'),
      body: json.encode({
        'name': name,
        'studentUsernames': students.map((student) => student.email).toList(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      if(response.statusCode == 400){
        throw InvalidDataException(response.body);
      }
      throw Exception('Failed to create class: ${response.body}');
    }

    return Class.fromJson(json.decode(response.body));
  }

  @override
  Future<void> deleteClass(Object id) async {
    final response = await _authenticatedClient.delete(
      Uri.parse('$_baseEndpoint/classes/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete class');
    }
  }

  @override
  Future<List<Class>> getAllClasses() async {
    final response = await _authenticatedClient.get(
      Uri.parse('$_baseEndpoint/classes'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get all classes');
    }

    return json
        .decode(response.body)
        .map<Class>((classData) => Class.fromJson(classData))
        .toList();
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
  Future<Class> updateClass(
    Object id,
    String name,
    List<AppUser> students,
  ) async {
    final response = await _authenticatedClient.put(
      Uri.parse('$_baseEndpoint/classes/$id'),
      body: json.encode({
        'name': name,
        'studentUsernames': students.map((student) => student.email).toList(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      if(response.statusCode == 204){
        throw NoChangesException(response.body);
      }
      throw Exception('Failed to update class');
    }

    return Class.fromJson(json.decode(response.body));
  }

  @override
  Future<List<String>> getAllSchools() async {
    final response = await http.get(
      Uri.parse('$_baseEndpoint/schools'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get all schools');
    }

    return json.decode(response.body).cast<String>();
  }
}
