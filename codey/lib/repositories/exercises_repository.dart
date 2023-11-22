import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/exercise.dart';

class ExercisesRepository {
  final String apiUrl = 'http://localhost:3000/api/v1/data/exercises';
  final Map<String, List<Exercise>> cache = {};

  Future<List<Exercise>> fetchExercises(String lessonId) async {
    if (cache.containsKey(lessonId)) {
      return cache[lessonId]!;
    }

    final response = await http.get(Uri.parse('$apiUrl?lessonId=$lessonId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final exercises = data.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
      cache[lessonId] = exercises;
      return exercises;
    } else {
      throw Exception('Failed to fetch exercises');
    }
  }

  Future<List<Exercise>> getExercisesForLesson(String lessonId) {
    if (cache.containsKey(lessonId)) {
      return Future.value(cache[lessonId]);
    }
    return fetchExercises(lessonId);
  }
}
