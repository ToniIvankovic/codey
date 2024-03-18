import 'dart:convert';

import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class LessonsRepository {
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup);
}

class LessonsRepository1 implements LessonsRepository {
  static Uri _apiUri(lessonGroup) =>
      Uri.parse('${dotenv.env["API_BASE"]}/lessons/lessonGroup/$lessonGroup');
  final Map<String, List<Lesson>> _cache = {};
  final http.Client _authenticatedClient;

  LessonsRepository1(this._authenticatedClient);

  @override
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup) {
    if (_cache.containsKey(lessonGroup.id.toString())) {
      return Future.value(_cache[lessonGroup.id.toString()]);
    }
    return _fetchLessonsForGroup(lessonGroup);
  }

  Future<List<Lesson>> _fetchLessonsForGroup(LessonGroup lessonGroup) async {
    var response = await _authenticatedClient.get(_apiUri(lessonGroup.id));

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException('Unauthorized retrieval of lessons');
        default:
          throw Exception('Failed to fetch lessons for group: ${lessonGroup.id}, '
              'Error ${response.statusCode}');
      }
    }

    final List<dynamic> data = json.decode(response.body);
    final lessons = data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
    // //TODO: sort on backend
    // lessons.sort((a, b) => a.id.compareTo(b.id));
    _cache[lessonGroup.id.toString()] = lessons;
    return lessons;
  }
}
