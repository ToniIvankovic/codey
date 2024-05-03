import 'dart:convert';

import 'package:codey/models/entities/end_of_lesson_response.dart';
import 'package:codey/models/entities/end_report.dart';
import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:codey/models/entities/exercise_statistics.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/student/exercises/single_exercise_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

abstract class ExercisesService {
  Future<void> startSessionForLesson(Lesson lesson, LessonGroup lessonGroup);
  Exercise? getNextExercise();
  Exercise? get currentExercise;
  bool get sessionActive;
  Future<int?> endSession(bool completed);
  Future<bool> checkAnswer(Exercise exercise, dynamic answer);
  EndReport? getEndReport();
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson);
  Future<List<Exercise>> getAllExercises();
  Future<void> deleteExercise(int exerciseId);
  Future<Exercise> createExercise(Exercise exercise);
  Future<Exercise> updateExercise(Exercise exercise);
  Future<void> startMockExerciseSession(Exercise exercise);
  Future<List<ExerciseStatistics>> calculateStatistics(
      List<Exercise> exercises);
  dynamic getCorrectAnswer(Exercise exercise);
  double get sessionProgress;
  IconButton generateExercisePreviewButton(
      BuildContext context, Exercise exercise);
  List<String> getExerciseDescriptionString(Exercise exercise);
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
  int? _totalExercisesInSession;
  bool _isMockInProgress = false;

  ExercisesServiceV1(
      this._exRepo, this._authenticatedClient, this._userService);

  @override
  double get sessionProgress {
    if (_totalExercisesInSession == null || _endReport == null) {
      return 0;
    }
    return _endReport!.totalAnswers / _totalExercisesInSession!;
  }

  @override
  Exercise? get currentExercise {
    return _currentExercise;
  }

  @override
  bool get sessionActive {
    return _sessionExercises != null;
  }

  @override
  Future<void> startSessionForLesson(
      Lesson lesson, LessonGroup lessonGroup) async {
    _sessionExercises = await getAllExercisesForLesson(lesson);
    _totalExercisesInSession = _sessionExercises!.length;
    _endReport = EndReport(
      lessonId: lesson.id,
      lessonGroupId: lessonGroup.id,
      correctAnswers: 0,
      totalAnswers: 0,
      totalExercises: _sessionExercises!.length,
    );
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
    const int mcDelay = 30;
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
      await Future.delayed(
        const Duration(milliseconds: mcDelay),
        () {},
      );
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
      var newExercise = Exercise.fromExercise(exercise);
      newExercise.repeated = true;
      _sessionExercises!.add(newExercise);
      _totalExercisesInSession = _totalExercisesInSession! + 1;
    }
    _endReport!.answersReport!.add(MapEntry(exercise.id, correct));
    return correct;
  }

  @override
  Future<int?> endSession(bool completed) async {
    _sessionExercises = null;
    if (!completed) {
      _endReport = null;
      _totalExercisesInSession = null;
      return null;
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
      //TODO: handle end of course
      return null;
    }

    EndOfLessonResponse endResponse =
        EndOfLessonResponse.fromJson(json.decode(response.body));
    _userService.updateUser(endResponse.appUser);
    return endResponse.awardedXP;
  }

  @override
  EndReport? getEndReport() {
    return _endReport;
  }

  @override
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson) {
    return _exRepo.getExercisesForLesson(lesson);
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
    _endReport = EndReport(
      lessonId: 0,
      lessonGroupId: 0,
      correctAnswers: 0,
      totalAnswers: 0,
      totalExercises: 1,
    );
    _totalExercisesInSession = 1;
    _isMockInProgress = true;
  }

  Future<bool> _mockCheckAnswer(Exercise exercise, answer) {
    //TODO: consider moving this check to backend
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

  @override
  Future<List<ExerciseStatistics>> calculateStatistics(
      List<Exercise> exercises) async {
    final response = await _authenticatedClient.post(
      Uri.parse("${dotenv.env["API_BASE"]}/exercises/calculate_statistics"),
      body: json.encode(exercises.map((e) => e.id).toList()),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to calculate statistics');
    }

    final data = json.decode(response.body);
    return List<ExerciseStatistics>.from(
        data.map((e) => ExerciseStatistics.fromJson(e)));
  }

  @override
  dynamic getCorrectAnswer(Exercise exercise) {
    if (exercise is ExerciseMC) {
      return exercise.answerOptions[exercise.correctAnswer];
    } else if (exercise is ExerciseSA) {
      return exercise.correctAnswers?[0];
    } else if (exercise is ExerciseLA) {
      return exercise.correctAnswers[0];
    } else if (exercise is ExerciseSCW) {
      return exercise.correctAnswers?.map((e) => e[0]).toList();
    } else {
      throw Exception('Unknown exercise type');
    }
  }

  @override
  IconButton generateExercisePreviewButton(
      BuildContext context, Exercise exercise) {
    return IconButton(
      icon: const Icon(Icons.remove_red_eye),
      onPressed: () {
        final exercisesService = context.read<ExercisesService>();
        exercisesService.startMockExerciseSession(exercise);
        exercisesService.getNextExercise();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Preview exercise ${exercise.id}'),
              ),
              body: SingleExerciseWidget(
                exercisesService: exercisesService,
                onSessionFinished: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  List<String> getExerciseDescriptionString(Exercise exercise) {
    if (exercise is ExerciseMC) {
      return [
        '${exercise.type.toString()} (${exercise.id})',
        '${exercise.statement ?? ''} ${exercise.statementCode?.replaceAll("\n", "↵") ?? ''} '
            '${exercise.statementOutput?.replaceAll("\n", "↵") ?? ''} ${exercise.question ?? ''} '
            '(${exercise.answerOptions.values.join(', ').replaceAll("\n", "↵")})'
      ];
    }
    if (exercise is ExerciseSA) {
      return [
        '${exercise.type.toString()} (${exercise.id})',
        ' - ${exercise.statement ?? ''} ${exercise.statementCode?.replaceAll("\n", "↵") ?? ''} '
            '${exercise.statementOutput?.replaceAll("\n", "↵") ?? ''} ${exercise.question ?? ''}'
      ];
    }
    if (exercise is ExerciseLA) {
      return [
        '${exercise.type.toString()} (${exercise.id})',
        '${exercise.statement ?? ''} ${exercise.statementOutput?.replaceAll("\n", "↵") ?? ''} '
            '(${exercise.answerOptions?.values.join(",").replaceAll("\n", "↵")})'
      ];
    }
    if (exercise is ExerciseSCW) {
      return [
        '${exercise.type.toString()} (${exercise.id})',
        '${exercise.statement ?? ''} ${exercise.statementCode.replaceAll("\n", "↵")} '
            '${exercise.statementOutput?.replaceAll("\n", "↵") ?? ''}'
      ];
    }
    throw Exception('Unknown exercise type');
  }
}
