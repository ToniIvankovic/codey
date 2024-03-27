import 'dart:convert';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/end_report.dart';
import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
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
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson);
  Future<List<Exercise>> getAllExercises();
  Future<void> deleteExercise(int exerciseId);
  Future<Exercise> createExercise(Exercise exercise);
  Future<Exercise> updateExercise(Exercise exercise);
  Future<void> startMockExerciseSession(Exercise exercise);
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
  bool _isMockInProgress = false;

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
    _sessionExercises = await getAllExercisesForLesson(lesson);
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
    if (_isMockInProgress) {
      return _mockCheckAnswer(exercise, answer);
    }
    bool correct;
    final request = _authenticatedClient.post(
      _exerciseAnswerValidationEndpoint(exercise),
      body: json.encode({"answer": answer}),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (exercise is ExerciseMC) {
      correct = exercise.correctAnswer == answer;
    } else if (exercise is ExerciseSA ||
        exercise is ExerciseLA ||
        exercise is ExerciseSCW) {
      final response = await request;
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

  @override
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson) {
    return _getAllExercisesForLessonById(lesson.id);
  }

  Future<List<Exercise>> _getAllExercisesForLessonById(int lessonId) {
    return _exRepo.getExercisesForLesson(lessonId);
  }

  @override
  Future<List<Exercise>> getAllExercises() {
    return _exRepo.getAllExercises();
  }

  @override
  Future<void> deleteExercise(int exerciseId) {
    return _exRepo.deleteExercise(exerciseId);
  }

  @override
  Future<Exercise> createExercise(Exercise exercise) {
    return _exRepo.createExercise(exercise);
  }

  @override
  Future<Exercise> updateExercise(Exercise exercise) {
    return _exRepo.updateExercise(exercise);
  }

  @override
  Future<void> startMockExerciseSession(Exercise exercise) async {
    _sessionExercises = [exercise];
    _endReport = EndReport(0, 0, 0, 1);
    _isMockInProgress = true;
  }

  Future<bool> _mockCheckAnswer(Exercise exercise, answer) {
    if (exercise is ExerciseMC) {
      return Future.value(exercise.correctAnswer == answer);
    } else if (exercise is ExerciseSA) {
      return Future.value(exercise.correctAnswers?.contains(answer) ?? false);
    } else if (exercise is ExerciseLA) {
      return Future.value(exercise.correctAnswers.contains(answer));
    } else if (exercise is ExerciseSCW) {
      List<String> answers = answer;
      if (exercise.correctAnswers == null ||
          exercise.correctAnswers!.length != answers.length) {
        return Future.value(false);
      }
      for (var i = 0; i < exercise.correctAnswers!.length; i++) {
        if (!exercise.correctAnswers![i].contains(answers[i])) {
          return Future.value(false);
        }
      }
      return Future.value(true);
    } else {
      throw Exception('Unknown exercise type');
    }
  }
}
