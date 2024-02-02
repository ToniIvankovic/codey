import 'dart:convert';

import 'package:codey/models/app_user.dart';
import 'package:codey/models/end_report.dart';
import 'package:codey/models/exercise.dart';
import 'package:codey/models/exercise_LA.dart';
import 'package:codey/models/exercise_MC.dart';
import 'package:codey/models/exercise_SA.dart';
import 'package:codey/models/lesson.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/services/user_service.dart';
import 'package:http/http.dart' as http;

abstract class ExercisesService {
  const ExercisesService();
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson);
  Future<List<Exercise>> getAllExercisesForLessonById(String lessonId);
  Future<void> startSessionForLesson(Lesson lesson);
  Exercise? getNextExercise();
  Exercise? get currentExercise;
  bool get sessionActive;
  void endSession(bool completed);
  Future<bool> checkAnswer(Exercise exercise, dynamic answer);
  EndReport? getEndReport();
}

class ExercisesServiceV1 implements ExercisesService {
  static String _exerciseAnswerValidationEndpoint(Exercise exercise) =>
      "http://localhost:5052/exercises/${exercise.id}";
  static const String _endOfSessionEndpoint =
      "http://localhost:5052/user/endedLesson";
  final ExercisesRepository exRepo;
  final http.Client _authenticatedClient;
  final UserService _userService;

  List<Exercise>? _sessionExercises;
  Exercise? _currentExercise;
  EndReport? _endReport;

  ExercisesServiceV1(this.exRepo, this._authenticatedClient, this._userService);

  @override
  Exercise? get currentExercise {
    return _currentExercise;
  }

  @override
  bool get sessionActive {
    return _sessionExercises != null;
  }

  @override
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson) {
    return getAllExercisesForLessonById(lesson.id.toString());
  }

  @override
  Future<List<Exercise>> getAllExercisesForLessonById(String lessonId) {
    return exRepo.fetchExercises(lessonId);
  }

  @override
  Future<void> startSessionForLesson(Lesson lesson) async {
    var exercises = await getAllExercisesForLesson(lesson);
    _sessionExercises = exercises;
    _endReport = EndReport(lesson.id, 0, 0, exercises.length, DateTime.now());
  }

  @override
  Exercise? getNextExercise() {
    if (_sessionExercises == null) {
      throw Exception('Session not active');
    }
    if (_sessionExercises!.isEmpty) {
      return null;
    }
    _currentExercise = _sessionExercises!.removeAt(0);
    return _currentExercise;
  }

  @override
  Future<bool> checkAnswer(Exercise exercise, dynamic answer) async {
    bool correct;
    if (exercise is ExerciseMC) {
      correct = exercise.correctAnswer == answer;
      _authenticatedClient.post(
        Uri.parse(_exerciseAnswerValidationEndpoint(exercise)),
        body: json.encode({"answer": answer}),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } else if (exercise is ExerciseSA || exercise is ExerciseLA) {
      final response = await _authenticatedClient.post(
        Uri.parse(_exerciseAnswerValidationEndpoint(exercise)),
        body: json.encode({"answer": answer}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        correct = data['isCorrect'];
      } else {
        throw Exception('Failed to validate answer');
      }
    } else {
      throw Exception('Unknown exercise type');
    }
    _endReport!.totalAnswers++;
    if (correct) {
      _endReport!.correctAnswers++;
    }
    return correct;
  }

  @override
  void endSession(bool completed) async {
    _sessionExercises = null;
    if (!completed) {
      _endReport = null;
      return;
    }
    
    if (_endReport == null) throw Exception('End report is null');

    var response = await _authenticatedClient.post(
      Uri.parse(_endOfSessionEndpoint),
      body: json.encode(_endReport!.toJson()),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      AppUser user = AppUser.fromJson(json.decode(response.body));
      _userService.updateUser(user);
    }
  }

  @override
  EndReport? getEndReport() {
    return _endReport;
  }
}
