import 'dart:convert';

import 'package:codey/models/entities/course.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class CoursesRepository {
  Future<List<Course>> getAllCourses();
}

class CoursesRepository1 implements CoursesRepository {
  final String _apiUrl = '${dotenv.env["API_BASE"]}/courses';
  final http.Client _client;
  List<Course>? _cache;

  CoursesRepository1(this._client);

  @override
  Future<List<Course>> getAllCourses() async {
    if (_cache != null) return _cache!;
    final response = await _client.get(Uri.parse(_apiUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load courses, Error ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    _cache = data.map((e) => Course.fromJson(e)).toList();
    return _cache!;
  }
}
