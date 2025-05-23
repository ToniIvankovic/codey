import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/entities/exercise.dart';

abstract class ExercisesRepository {
  Future<List<Exercise>> getExercisesForLesson(Lesson lesson);
  Future<List<Exercise>> getAllExercises();
  Future<void> deleteExercise(int exerciseId);
  Future<Exercise> createExercise(Exercise exercise);
  void invalidateCache(int? id);
  Future<Exercise> updateExercise(Exercise exercise);
}

class ExercisesRepository1 implements ExercisesRepository {
  static Uri _apiUrl(lessonId) =>
      Uri.parse('${dotenv.env["API_BASE"]}/exercises/lesson/$lessonId');
  static final Uri _apiAdaptiveUrl =
      Uri.parse('${dotenv.env["API_BASE"]}/exercises/lesson/adaptive');
  final Map<int, List<Exercise>> cachedLessonExercises = {};
  final http.Client _authenticatedClient;

  ExercisesRepository1(this._authenticatedClient);

  @override
  Future<List<Exercise>> getExercisesForLesson(Lesson lesson) {
    if (cachedLessonExercises.containsKey(lesson.id)) {
      return Future.value(List.of(cachedLessonExercises[lesson.id]!));
    }
    return _fetchExercises(lesson);
  }

  Future<List<Exercise>> _fetchExercises(Lesson lesson) async {
    final uri = lesson.adaptive ? _apiAdaptiveUrl : _apiUrl(lesson.id);
    final response = await _authenticatedClient.get(uri);

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException(
              'Unauthenticated retrieval of exercises');
        default:
          throw Exception('Failed to fetch exercises, '
              'Error ${response.statusCode}');
      }
    }

    final List<dynamic> data = json.decode(response.body);
    final exercises =
        data.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
    for (var exercise in exercises) {
      if (exercise is ExerciseMC) {
        exercise.answerOptions.forEach((key, value) {
          if (value == "error_message") {
            exercise.answerOptions[key] = "* Dogodit će se greška *";
          }
        });
      }
    }
    if (!lesson.adaptive) {
      cachedLessonExercises[lesson.id] = exercises;
    }
    return List.of(exercises);
  }

  @override
  Future<List<Exercise>> getAllExercises() async {
    final uri = Uri.parse('${dotenv.env["API_BASE"]}/exercises');
    final response = await _authenticatedClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch exercises, '
          'Error ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    return data.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
  }

  @override
  void invalidateCache(int? id) {
    if (id != null) {
      cachedLessonExercises.remove(id);
    } else {
      cachedLessonExercises.clear();
    }
  }

  @override
  Future<void> deleteExercise(int exerciseId) async {
    final uri = Uri.parse('${dotenv.env["API_BASE"]}/exercises/$exerciseId');
    final response = await _authenticatedClient.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete exercise, '
          'Error ${response.statusCode}');
    }
  }

  @override
  Future<Exercise> createExercise(Exercise exercise) async {
    final uri = Uri.parse('${dotenv.env["API_BASE"]}/exercises');
    var jsonBody = exercise.toJson();
    jsonBody.remove('id');
    final response = await _authenticatedClient
        .post(uri, body: json.encode(jsonBody), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to create exercise');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return Exercise.fromJson(data);
  }

  @override
  Future<Exercise> updateExercise(Exercise exercise) async {
    final uri = Uri.parse('${dotenv.env["API_BASE"]}/exercises/${exercise.id}');
    var jsonBody = exercise.toJson();
    jsonBody.remove('id');

    final response = await _authenticatedClient
        .put(uri, body: json.encode(jsonBody), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      if (response.statusCode == 204) {
        throw NoChangesException('No changes');
      }
      throw Exception('Failed to update exercise');
    }

    invalidateCache(null);
    final Map<String, dynamic> data = json.decode(response.body);
    return Exercise.fromJson(data);
  }
}
