import 'dart:convert';

import 'package:codey/models/lesson.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LessonsRepository {
  final String apiUrl = '${dotenv.env["API_BASE"]}/Lessons';
  final Map<String, List<Lesson>> _cache = {};
  final http.Client _authenticatedClient;

  LessonsRepository(this._authenticatedClient);

  Future<List<Lesson>> _fetchLessonsForGroup(String lessonGroup) async {
    if (_cache.containsKey(lessonGroup)) {
      return _cache[lessonGroup]!;
    }

    try {
      var response = await _authenticatedClient
          .get(Uri.parse('$apiUrl/lessonGroup/$lessonGroup'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final lessons =
            data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
        _cache[lessonGroup] = lessons;
        return lessons;
      } else {
        throw Exception(
            'Failed to fetch lessons for group: $lessonGroup, Error ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Lesson>> getLessonsForGroup(String lessonGroup) {
    if (_cache.containsKey(lessonGroup)) {
      return Future.value(_cache[lessonGroup]);
    }
    return _fetchLessonsForGroup(lessonGroup);
  }
}
