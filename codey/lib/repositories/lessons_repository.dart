import 'dart:convert';

import 'package:codey/models/lesson.dart';
import 'package:http/http.dart' as http;


class LessonsRepository {
  final String apiUrl = 'http://localhost:5052/Lessons';
  final Map<String, List<Lesson>> _cache = {};

  Future<List<Lesson>> _fetchLessonsForGroup(String lessonGroup) async {
    if (_cache.containsKey(lessonGroup)) {
      return _cache[lessonGroup]!;
    }

    try {
      final response =
          await http.get(Uri.parse('$apiUrl/lessonGroup/$lessonGroup'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final lessons =
            data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
        _cache[lessonGroup] = lessons;
        return lessons;
      } else {
        throw Exception('Failed to fetch lessons for group: $lessonGroup');
      }
    } catch (e) {
      throw Exception('Failed to fetch lessons for group: $lessonGroup,$e');
    }
  }

  Future<List<Lesson>> getLessonsForGroup(String lessonGroup) {
    if (_cache.containsKey(lessonGroup)) {
      return Future.value(_cache[lessonGroup]);
    }
    return _fetchLessonsForGroup(lessonGroup);
  }
}
