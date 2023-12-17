import 'package:codey/models/exercise_type.dart';

import 'exercise.dart';

class ExerciseMC extends Exercise {
  Map<String, dynamic> answerOptions;
  String correctAnswer;

  ExerciseMC({
    required id,
    required difficulty,
    type = ExerciseType.MC,
    String? statement,
    String? statementCode,
    String? question,
    String? specificTip,
    required this.answerOptions,
    required this.correctAnswer,
  }) : super(
          id: id,
          difficulty: difficulty,
          type: type,
          statement: statement,
          statementCode: statementCode,
          question: question,
          specificTip: specificTip,
        );

  factory ExerciseMC.fromJson(Map<String, dynamic> json) {
    return ExerciseMC(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      question: json['question'],
      specificTip: json['specificTip'],
      answerOptions: json['answerOptions'],
      correctAnswer: json['correctAnswer'],
    );
  }
}
