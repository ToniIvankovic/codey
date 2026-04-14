import 'dart:convert';

import 'package:codey/models/DTOs/lesson_creation_dto.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

abstract class LessonsRepository {
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup);
  Future<List<Lesson>> getAllLessons();
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds);
  void invalidateCache(int? lessonId);
  Future<Lesson> createLesson(String name, String? tips, List<int> exerciseIds, {int? exerciseLimit});
  void deleteLesson(Lesson lesson);
  Future<Lesson> updateLesson(int id, String name, String? tips, List<int> exerciseIds, {int? exerciseLimit});
}

class LessonsRepository1 implements LessonsRepository {
  static final Uri _apiUriAll =
      Uri.parse('${dotenv.env["API_BASE"]}/lessons/all');

  final http.Client _authenticatedClient;
  final UserService _userService;
  final Map<int, Lesson> _lessonCache = {};

  LessonsRepository1(
    this._authenticatedClient,
    this._userService,
    SessionService sessionService,
  ) {
    Rx.merge([
      _userService.courseChanged,
      sessionService.logoutStream,
    ]).listen((_) => invalidateCache(null));
  }

  @override
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup) async {
    final response = await _authenticatedClient.get(Uri.parse(
        '${dotenv.env["API_BASE"]}/lessons/lessonGroup/${lessonGroup.id}'));
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException(
              'Unauthorized retrieval of lessons for group');
        default:
          throw Exception(
              'Failed to fetch lessons for group, Error ${response.statusCode}');
      }
    }

    final List<dynamic> data = json.decode(response.body);
    final lessons =
        data.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
    if (!lessonGroup.adaptive) {
      for (var lesson in lessons) {
        _lessonCache[lesson.id] = lesson;
      }
    }
    return lessons;
  }

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
    _lessonCache.clear();
    for (var lesson in lessons) {
      _lessonCache[lesson.id] = lesson;
    }
    return lessons;
  }

  @override
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds) async {
    final lessons = <Lesson>[];
    final lessonsToFetch = <int>[];
    for (var id in lessonIds) {
      if (_lessonCache.containsKey(id)) {
        lessons.add(_lessonCache[id]!);
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
        _lessonCache[lesson.id] = lesson;
      }
    }

    return lessons;
  }

  @override
  void invalidateCache(int? lessonId) {
    if (lessonId == null) {
      _lessonCache.clear();
    } else {
      _lessonCache.remove(lessonId);
    }
  }

  @override
  Future<Lesson> createLesson(
    String name,
    String? tips,
    List<int> exerciseIds, {
    int? exerciseLimit,
  }) async {
    var apiUri = Uri.parse('${dotenv.env["API_BASE"]}/lessons');
    var courseId = (await _userService.userStream.first).course.id;
    var dto = LessonCreationDto(
      name: name,
      specificTips: tips,
      exerciseIds: exerciseIds,
      courseId: courseId,
      exerciseLimit: exerciseLimit,
    );
    final response = await _authenticatedClient.post(
      apiUri,
      body: json.encode(dto.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException('Unauthenticated');
        case 403:
          throw UnauthenticatedException('Unauthorized creation of lesson');
        default:
          throw Exception(
              'Failed to create lesson, Error ${response.statusCode}');
      }
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final lesson = Lesson.fromJson(data);
    _lessonCache[lesson.id] = lesson;
    return lesson;
  }

  @override
  void deleteLesson(Lesson lesson) async {
    invalidateCache(lesson.id);
    final response = await _authenticatedClient
        .delete(Uri.parse('${dotenv.env["API_BASE"]}/lessons/${lesson.id}'));
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
        case 403:
          throw UnauthenticatedException('Unauthorized deletion of lesson');
        default:
          throw Exception(
              'Failed to delete lesson, Error ${response.statusCode}');
      }
    }
  }

  @override
  Future<Lesson> updateLesson(
    int id,
    String name,
    String? tips,
    List<int> exerciseIds, {
    int? exerciseLimit,
  }) async {
    invalidateCache(id);
    var courseId = (await _userService.userStream.first).course.id;
    var dto = LessonCreationDto(
      name: name,
      specificTips: tips,
      exerciseIds: exerciseIds,
      courseId: courseId,
      exerciseLimit: exerciseLimit,
    );
    var response = await _authenticatedClient.put(
        Uri.parse('${dotenv.env["API_BASE"]}/lessons/$id'),
        body: json.encode(dto.toJson()),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException('Unauthorized update of lesson');
        case 204:
          throw NoChangesException("No changes made");
        default:
          throw Exception(
              'Failed to update lesson, Error ${response.statusCode}');
      }
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final lesson = Lesson.fromJson(data);
    _lessonCache[lesson.id] = lesson;
    return lesson;
  }
}
