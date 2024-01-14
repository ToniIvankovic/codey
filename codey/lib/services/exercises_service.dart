import 'package:codey/models/exercise.dart';
import 'package:codey/models/exercise_MC.dart';
import 'package:codey/models/lesson.dart';
import 'package:codey/repositories/exercises_repository.dart';

abstract class ExercisesService {
  const ExercisesService();
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson);
  Future<List<Exercise>> getAllExercisesForLessonById(String lessonId);
  Future<void> startSessionForLesson(Lesson lesson);
  Exercise? getNextExercise();
  Exercise? get currentExercise;
  void endSession();
  bool checkAnswer(Exercise exercise, dynamic answer);
}

class ExercisesServiceV1 implements ExercisesService {
  final ExercisesRepository exRepo;
  ExercisesServiceV1(this.exRepo);
  bool _isSessionActive = false;
  List<Exercise>? _sessionExercises;
  Exercise? _currentExercise;
  @override
  Exercise? get currentExercise {
    return _currentExercise;
  }

  //function to get all lessons
  @override
  Future<List<Exercise>> getAllExercisesForLesson(Lesson lesson) {
    return exRepo.fetchExercises(lesson.id.toString());
  }

  @override
  Future<List<Exercise>> getAllExercisesForLessonById(String lessonId) {
    return exRepo.fetchExercises(lessonId);
  }

  @override
  Future<void> startSessionForLesson(Lesson lesson) async {
    // if (_isSessionActive) {
    //   throw Exception('Session already active');
    // }
    _isSessionActive = true;
    var exercises = await getAllExercisesForLesson(lesson);
    _sessionExercises = exercises;
  }

  @override
  Exercise? getNextExercise() {
    if (_sessionExercises == null) {
      throw Exception('Session not active');
    }
    if (_sessionExercises!.isEmpty) {
      endSession();
      return null;
    }
    _currentExercise = _sessionExercises!.removeAt(0);
    return _currentExercise;
  }

  @override
  void endSession() {
    _isSessionActive = false;
    _sessionExercises = null;
  }

  @override
  bool checkAnswer(Exercise exercise, dynamic answer) {
    if (exercise is ExerciseMC) {
      return exercise.correctAnswer == answer;
    } else {
      throw Exception('Unknown exercise type');
    }
  }
}
