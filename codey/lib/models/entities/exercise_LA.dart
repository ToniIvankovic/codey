// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';
import 'exercise.dart';

class ExerciseLA extends Exercise {
  Map<String, String>? answerOptions;
  List<String> correctAnswers = [];

  ExerciseLA({
    required id,
    required difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
    this.answerOptions,
    required this.correctAnswers,
  }) : super(
          type: ExerciseType.LA,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementOutput: statementOutput,
          specificTip: specificTip,
        );

  factory ExerciseLA.fromJson(Map<String, dynamic> json) {
    return ExerciseLA(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementOutput: json['statementOutput'],
      specificTip: json['specificTip'],
      answerOptions: (json['answerOptions'] as Map<String, dynamic>)
          .cast<String, String>(),
      correctAnswers: json['correctAnswers'] != null
          ? List<String>.from(json['correctAnswers'])
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'type': type.toString(),
        'statement': statement,
        'statementOutput': statementOutput,
        'specificTip': specificTip,
        'answerOptions': answerOptions,
        'correctAnswers': correctAnswers,
      };
}
