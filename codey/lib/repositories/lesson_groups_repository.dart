import 'dart:convert';

import 'package:codey/models/lesson_group.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class LessonGroupsRepository {
  final String apiUrl = 'http://localhost:5052/lessonGroups';
  List<LessonGroup>? _lessonGroupsCache;

  Future<List<LessonGroup>> fetchLessonGroups() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      Future<void> sleep() async {
        await Future.delayed(Duration(seconds: 3));
      }

      // Usage:
      await sleep();

      if (response.statusCode == 200) {
        // Parse the response body and extract the lesson groups
        final List<dynamic> data = json.decode(response.body);
        final List<LessonGroup> lessonGroups =
            data.map((dynamic item) => LessonGroup.fromJson(item)).toList();
        _lessonGroupsCache = lessonGroups; // Update the cache
        return lessonGroups;
      } else {
        throw Exception('Failed to fetch lesson groups');
      }
    } catch (e) {
      throw Exception('Failed to fetch lesson groups: $e');
    }
  }

  Future<List<LessonGroup>> get lessonGroups {
    if (_lessonGroupsCache == null) {
      // Cache not initialized, fetch the lesson groups
      return fetchLessonGroups();
    }
    return Future.value(_lessonGroupsCache);
  }
}
