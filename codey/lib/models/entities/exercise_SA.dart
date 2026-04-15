// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';

import 'exercise.dart';

class ExerciseSA extends Exercise {
  final String? statementCode;
  final String? question;
  final List<String>? correctAnswers;
  final bool? raisesError;

  ExerciseSA({
    required id,
    required difficulty,
    String? statement,
    this.statementCode,
    String? statementOutput,
    this.question,
    String? specificTip,
    String? imageUrl,
    this.correctAnswers,
    this.raisesError,
    required courseId,
  }) : super(
          type: ExerciseType.SA,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementOutput: statementOutput,
          specificTip: specificTip,
          imageUrl: imageUrl,
          courseId: courseId,
        );

  factory ExerciseSA.fromJson(Map<String, dynamic> json) {
    return ExerciseSA(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      statementOutput: json['statementOutput'],
      question: json['question'],
      specificTip: json['specificTip'],
      imageUrl: json['imageUrl'],
      correctAnswers: json['correctAnswers'] != null
          ? List<String>.from(json['correctAnswers'])
          : null,
      raisesError: json['raisesError'],
      courseId: json['courseId'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'type': type.toString(),
        'statement': statement,
        'statementCode': statementCode,
        'statementOutput': statementOutput,
        'question': question,
        'specificTip': specificTip,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'correctAnswers': correctAnswers,
        'raisesError': raisesError,
        'courseId': courseId,
      };

  factory ExerciseSA.fromExercise(ExerciseSA other) {
    return ExerciseSA(
      id: other.id,
      difficulty: other.difficulty,
      statement: other.statement,
      statementCode: other.statementCode,
      statementOutput: other.statementOutput,
      specificTip: other.specificTip,
      imageUrl: other.imageUrl,
      question: (other).question,
      correctAnswers: (other).correctAnswers,
      raisesError: (other).raisesError,
      courseId: other.courseId,
    );
  }
}
