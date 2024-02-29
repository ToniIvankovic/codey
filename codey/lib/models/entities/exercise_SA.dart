// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';

import 'exercise.dart';

class ExerciseSA extends Exercise {
  ExerciseSA({
    required id,
    required difficulty,
    String? statement,
    String? statementCode,
    String? question,
    String? specificTip,
  }) : super(
          type: ExerciseType.SA,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementCode: statementCode,
          question: question,
          specificTip: specificTip,
        );

  factory ExerciseSA.fromJson(Map<String, dynamic> json) {
    return ExerciseSA(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      question: json['question'],
      specificTip: json['specificTip'],
    );
  }
}
