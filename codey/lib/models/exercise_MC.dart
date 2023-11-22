import 'package:codey/models/exercise_type.dart';

import 'exercise.dart';

class ExerciseMC extends Exercise {
  List<String> answerOptions;
  String correctAnswer;

  ExerciseMC({
    required int id,
    required double difficulty,
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
      id: json['id'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      question: json['question'],
      specificTip: json['specificTip'],
      answerOptions: json['answerOptions'].cast<String>(),
      correctAnswer: json['correctAnswer'],
    );
  }
}
