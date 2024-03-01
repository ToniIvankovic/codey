import 'dart:convert';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/end_report.dart';
import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class ExercisesService {
  Future<void> startSessionForLesson(Lesson lesson);
  Exercise? getNextExercise();
  Exercise? get currentExercise;
  bool get sessionActive;
  void endSession(bool completed);
  Future<bool> checkAnswer(Exercise exercise, dynamic answer);
  EndReport? getEndReport();
}

class ExercisesServiceV1 implements ExercisesService {
  static Uri _exerciseAnswerValidationEndpoint(Exercise exercise) =>
      Uri.parse("${dotenv.env["API_BASE"]}/exercises/${exercise.id}");
  static final Uri _endOfSessionEndpoint =
      Uri.parse("${dotenv.env["API_BASE"]}/user/endedLesson");

  final ExercisesRepository _exRepo;
  final http.Client _authenticatedClient;
  final UserService _userService;

  List<Exercise>? _sessionExercises;
  Exercise? _currentExercise;
  EndReport? _endReport;

  ExercisesServiceV1(
      this._exRepo, this._authenticatedClient, this._userService);

  @override
  Exercise? get currentExercise {
    return _currentExercise;
  }

  @override
  bool get sessionActive {
    return _sessionExercises != null;
  }

  @override
  Future<void> startSessionForLesson(Lesson lesson) async {
    _sessionExercises = await _getAllExercisesForLesson(lesson);
    _endReport = EndReport(lesson.id, 0, 0, _sessionExercises!.length);
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
        _exerciseAnswerValidationEndpoint(exercise),
        body: json.encode({"answer": answer}),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } else if (exercise is ExerciseSA || exercise is ExerciseLA) {
      final response = await _authenticatedClient.post(
        _exerciseAnswerValidationEndpoint(exercise),
        body: json.encode({"answer": answer}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to validate answer');
      }

      final data = json.decode(response.body);
      correct = data['isCorrect'];
    } else {
      throw Exception('Unknown exercise type');
    }

    _endReport!.totalAnswers++;
    if (correct) {
      _endReport!.correctAnswers++;
    } else {
      // TODO: indicate that the exercise is repeated
      _sessionExercises!.add(exercise);
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
      _endOfSessionEndpoint,
      body: json.encode(_endReport!.toJson()),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      return;
    }

    AppUser user = AppUser.fromJson(json.decode(response.body));
    _userService.updateUser(user);
  }

  @override
  EndReport? getEndReport() {
    return _endReport;
  }

  Future<List<Exercise>> _getAllExercisesForLesson(Lesson lesson) {
    return _getAllExercisesForLessonById(lesson.id.toString());
  }

  Future<List<Exercise>> _getAllExercisesForLessonById(String lessonId) {
    return _exRepo.getExercisesForLesson(lessonId);
  }
}
