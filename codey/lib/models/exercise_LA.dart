import 'package:codey/models/exercise_type.dart';

import 'exercise.dart';

class ExerciseLA extends Exercise {
  dynamic answerChecker;

  ExerciseLA({
    required id,
    required difficulty,
    type = ExerciseType.LA,
    String? statement,
    String? statementCode,
    String? question,
    String? specificTip,
    required dynamic answerChecker,
  }) : super(
          id: id,
          difficulty: difficulty,
          type: type,
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
      answerChecker: json['answerChecker'],
    );
  }
}
