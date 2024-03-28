import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/entities/exercise.dart';

abstract class ExercisesRepository {
  Future<List<Exercise>> getExercisesForLesson(int lessonId);
  Future<List<Exercise>> getAllExercises();
  Future<void> deleteExercise(int exerciseId);
  Future<Exercise> createExercise(Exercise exercise);
  void invalidateCache(int? id);
  Future<Exercise> updateExercise(Exercise exercise);
}

class ExercisesRepository1 implements ExercisesRepository {
  static Uri _apiUrl(lessonId) =>
      Uri.parse('${dotenv.env["API_BASE"]}/exercises/lesson/$lessonId');
  final Map<int, List<Exercise>> cachedLessonExercises = {};
  final http.Client _authenticatedClient;

  ExercisesRepository1(this._authenticatedClient);

  @override
  Future<List<Exercise>> getExercisesForLesson(int lessonId) {
    if (cachedLessonExercises.containsKey(lessonId)) {
      return Future.value(List.of(cachedLessonExercises[lessonId]!));
    }
    return _fetchExercises(lessonId);
  }

  Future<List<Exercise>> _fetchExercises(int lessonId) async {
    final uri = _apiUrl(lessonId);
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
    cachedLessonExercises[lessonId] = exercises;
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
      if(response.statusCode == 204){
        throw NoChangesException('No changes');
      }
      throw Exception('Failed to update exercise');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return Exercise.fromJson(data);
  }
}
