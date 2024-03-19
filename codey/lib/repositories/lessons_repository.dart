import 'dart:convert';

import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class LessonsRepository {
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup);
  Future<List<Lesson>> getAllLessons();
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds);
  void invalidateCache(Lesson? lesson);
}

class LessonsRepository1 implements LessonsRepository {
  static Uri _apiUri(lessonGroup) =>
      Uri.parse('${dotenv.env["API_BASE"]}/lessons/lessonGroup/$lessonGroup');
  static final Uri _apiUriAll = Uri.parse('${dotenv.env["API_BASE"]}/lessons/all');

  final Map<int, Lesson> _cache = {};
  final http.Client _authenticatedClient;

  LessonsRepository1(this._authenticatedClient);

  @override
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup) async {
    List<int> lessonIds = lessonGroup.lessons;
    return getLessonsByIds(lessonIds);
  }

  // Future<List<Lesson>> _fetchLessonsForGroup(LessonGroup lessonGroup) async {
  //   var response = await _authenticatedClient.get(_apiUri(lessonGroup.id));

  //   if (response.statusCode != 200) {
  //     switch (response.statusCode) {
  //       case 401:
  //         throw UnauthenticatedException('Unauthorized retrieval of lessons');
  //       default:
  //         throw Exception(
  //             'Failed to fetch lessons for group: ${lessonGroup.id}, '
  //             'Error ${response.statusCode}');
  //     }
  //   }

  //   final List<dynamic> data = json.decode(response.body);
  //   final lessons =
  //       data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
  //   // //TODO: sort on backend
  //   // lessons.sort((a, b) => a.id.compareTo(b.id));
  //   _cache[lessonGroup.id.toString()] = lessons;
  //   return lessons;
  // }

  @override
  Future<List<Lesson>> getAllLessons() async {
    var response = await _authenticatedClient.get(_apiUriAll);

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException('Unauthorized retrieval of lessons');
        default:
          throw Exception(
              'Failed to fetch all lessons, Error ${response.statusCode}');
      }
    }

    final List<dynamic> data = json.decode(response.body);
    final lessons =
        data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
    return lessons;
  }

  @override
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds) async {
    final lessons = <Lesson>[];
    final lessonsToFetch = <int>[];
    for (var id in lessonIds) {
      if (_cache.containsKey(id)) {
        lessons.add(_cache[id]!);
      } else {
        lessonsToFetch.add(id);
      }
    }

    if (lessonsToFetch.isNotEmpty) {
      final response = await _authenticatedClient.get(Uri.parse(
          '${dotenv.env["API_BASE"]}/lessons?ids=${lessonsToFetch.join('&ids=')}'));
      if (response.statusCode != 200) {
        switch (response.statusCode) {
          case 401:
            throw UnauthenticatedException('Unauthorized retrieval of lessons');
          default:
            throw Exception(
                'Failed to fetch lessons by ids: ${lessonsToFetch.join(',')}, '
                'Error ${response.statusCode}');
        }
      }

      final List<dynamic> data = json.decode(response.body);
      final fetchedLessons =
          data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
      lessons.addAll(fetchedLessons);
      for (var lesson in fetchedLessons) {
        _cache[lesson.id] = lesson;
      }
    }

    lessons.sort((a, b) => lessonIds.indexOf(a.id).compareTo(lessonIds.indexOf(b.id)));
    return lessons;
  }

  @override
  void invalidateCache(Lesson? lesson) {
    if (lesson == null) {
      _cache.clear();
    } else {
      _cache.remove(lesson.id);
    }
  }
}
