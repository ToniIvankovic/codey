import 'dart:convert';

import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class LessonsRepository {
  Future<List<Lesson>> getLessonsForGroup(String lessonGroup);
}

class LessonsRepository1 implements LessonsRepository {
  static Uri _apiUri(lessonGroup) =>
      Uri.parse('${dotenv.env["API_BASE"]}/Lessons/lessonGroup/$lessonGroup');
  final Map<String, List<Lesson>> _cache = {};
  final http.Client _authenticatedClient;

  LessonsRepository1(this._authenticatedClient);

  @override
  Future<List<Lesson>> getLessonsForGroup(String lessonGroup) {
    if (_cache.containsKey(lessonGroup)) {
      return Future.value(_cache[lessonGroup]);
    }
    return _fetchLessonsForGroup(lessonGroup);
  }

  Future<List<Lesson>> _fetchLessonsForGroup(String lessonGroup) async {
    var response = await _authenticatedClient.get(_apiUri(lessonGroup));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final lessons =
          data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
      _cache[lessonGroup] = lessons;
      return lessons;
    } else if (response.statusCode == 401) {
      throw UnauthenticatedException('Unauthorized retrieval of lessons');
    } else {
      throw Exception('Failed to fetch lessons for group: $lessonGroup, '
          'Error ${response.statusCode}');
    }
  }
}
