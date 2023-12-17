import 'package:codey/models/exercise_type.dart';

import 'exercise.dart';

class ExerciseSA extends Exercise {
  dynamic answerChecker;

  ExerciseSA({
    required id,
    required difficulty,
    type = ExerciseType.SA,
    String? statement,
    String? statementCode,
    String? question,
    String? specificTip,
    required dynamic answerChecker,
    bool? raisesError,
  }) : super(
          id: id,
          difficulty: difficulty,
          type: type,
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
      answerChecker: json['answerChecker'],
    );
  }
}
