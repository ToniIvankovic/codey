import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/entities/exercise.dart';

abstract class ExercisesRepository {
  Future<List<Exercise>> getExercisesForLesson(String lessonId);
}

class ExercisesRepository1 implements ExercisesRepository {
  static Uri _apiUrl(lessonId) =>
      Uri.parse('${dotenv.env["API_BASE"]}/exercises/lesson/$lessonId');
  final Map<String, List<Exercise>> cache = {};
  final http.Client _authenticatedClient;

  ExercisesRepository1(this._authenticatedClient);

  @override
  Future<List<Exercise>> getExercisesForLesson(String lessonId) {
    if (cache.containsKey(lessonId)) {
      return Future.value(List.of(cache[lessonId]!));
    }
    return _fetchExercises(lessonId);
  }

  Future<List<Exercise>> _fetchExercises(String lessonId) async {
    final uri = _apiUrl(lessonId);
    final response = await _authenticatedClient.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final exercises =
          data.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
      cache[lessonId] = exercises;
      return List.of(exercises);
    } else {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException(
              'Unauthenticated retrieval of exercises');
        default:
          throw Exception('Failed to fetch exercises, '
              'Error ${response.statusCode}');
      }
    }
  }
}
