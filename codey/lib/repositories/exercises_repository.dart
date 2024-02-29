import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/exercise.dart';

class ExercisesRepository {
  final String apiUrl = '${dotenv.env["API_BASE"]}/exercises';
  final Map<String, List<Exercise>> cache = {};
  final http.Client _authenticatedClient;

  ExercisesRepository(this._authenticatedClient);

  Future<List<Exercise>> fetchExercises(String lessonId) async {
    final response = await _authenticatedClient.get(Uri.parse('$apiUrl/lesson/$lessonId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final exercises = data.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
      cache[lessonId] = exercises;
      return List.of(exercises);
    } else {
      throw Exception('Failed to fetch exercises');
    }
  }

  Future<List<Exercise>> getExercisesForLesson(String lessonId) {
    if (cache.containsKey(lessonId)) {
      return Future.value(List.of(cache[lessonId]!));
    }
    return fetchExercises(lessonId);
  }
}
