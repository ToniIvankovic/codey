// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';
import 'exercise.dart';

class ExerciseLA extends Exercise {
  ExerciseLA({
    required id,
    required difficulty,
    String? statement,
    String? statementCode,
    String? question,
    String? specificTip,
  }) : super(
          type: ExerciseType.LA,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementCode: statementCode,
          question: question,
          specificTip: specificTip,
        );

  factory ExerciseLA.fromJson(Map<String, dynamic> json) {
    return ExerciseLA(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      question: json['question'],
      specificTip: json['specificTip'],
    );
  }
}
