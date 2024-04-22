import 'dart:convert';

import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class LessonsRepository {
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup);
  Future<List<Lesson>> getAllLessons();
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds);
  void invalidateCache(int? lessonId);
  Future<Lesson> createLesson(String name, String? tips, List<int> exerciseIds);
  void deleteLesson(Lesson lesson);
  Future<Lesson> updateLesson(
      int id, String name, String? tips, List<int> exerciseIds);
}

class LessonsRepository1 implements LessonsRepository {
  static final Uri _apiUriAll =
      Uri.parse('${dotenv.env["API_BASE"]}/lessons/all');

  final Map<int, Lesson> _cache = {};
  final http.Client _authenticatedClient;
  final ExercisesRepository _exercisesRepository;

  LessonsRepository1(this._authenticatedClient, this._exercisesRepository);

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
        _cache[lesson.id] = lesson;
      }
    }
    return lessons;
    // List<int> lessonIds = lessonGroup.lessons;
    // return getLessonsByIds(lessonIds);
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
    invalidateCache(null);
    for (var lesson in lessons) {
      _cache[lesson.id] = lesson;
    }
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

    lessons.sort(
        (a, b) => lessonIds.indexOf(a.id).compareTo(lessonIds.indexOf(b.id)));
    return lessons;
  }

  @override
  void invalidateCache(int? lessonId) {
    if (lessonId == null) {
      _cache.clear();
      _exercisesRepository.invalidateCache(null);
    } else {
      _cache.remove(lessonId);
      _exercisesRepository.invalidateCache(lessonId);
    }
  }

  @override
  Future<Lesson> createLesson(
    String name,
    String? tips,
    List<int> exerciseIds,
  ) async {
    var apiUri = Uri.parse('${dotenv.env["API_BASE"]}/lessons');
    final response = await _authenticatedClient.post(
      apiUri,
      body: json.encode({
        'name': name,
        'specificTips': tips,
        'exercises': exerciseIds,
      }),
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
    _cache[lesson.id] = lesson;
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
    List<int> exerciseIds,
  ) async {
    invalidateCache(id);
    var response = await _authenticatedClient
        .put(Uri.parse('${dotenv.env["API_BASE"]}/lessons/$id'),
            body: json.encode({
              'name': name,
              'specificTips': tips ?? "", //TODO: maybe leave null?
              'exercises': exerciseIds,
            }),
            headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException('Unauthorized update of lesson');
        default:
          throw Exception(
              'Failed to update lesson, Error ${response.statusCode}');
      }
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final lesson = Lesson.fromJson(data);
    _cache[lesson.id] = lesson;
    return lesson;
  }
}
