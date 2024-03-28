// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';

import 'exercise.dart';

class ExerciseMC extends Exercise {
  String? statementCode;
  String? question;
  Map<String, dynamic> answerOptions;
  String correctAnswer;

  ExerciseMC({
    required id,
    required difficulty,
    String? statement,
    this.statementCode,
    this.question,
    String? specificTip,
    String? statementOutput,
    required this.answerOptions,
    required this.correctAnswer,
  }) : super(
          id: id,
          difficulty: difficulty,
          type: ExerciseType.MC,
          statement: statement,
          statementOutput: statementOutput,
          specificTip: specificTip,
        );

  factory ExerciseMC.fromJson(Map<String, dynamic> json) {
    return ExerciseMC(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      statementOutput: json['statementOutput'],
      question: json['question'],
      specificTip: json['specificTip'],
      answerOptions: json['answerOptions'],
      correctAnswer: json['correctAnswer'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'difficulty': difficulty,
      'type': type.toString(),
      'answerOptions': answerOptions,
      'correctAnswer': correctAnswer,
    };

    if (statement != null) {
      json['statement'] = statement;
    }
    if (statementCode != null) {
      json['statementCode'] = statementCode;
    }
    if (statementOutput != null) {
      json['statementOutput'] = statementOutput;
    }
    if (question != null) {
      json['question'] = question;
    }
    if (specificTip != null) {
      json['specificTip'] = specificTip;
    }

    return json;
  }
}
