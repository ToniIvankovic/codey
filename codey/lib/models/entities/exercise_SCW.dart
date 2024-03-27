// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';

import 'exercise.dart';

class ExerciseSCW extends Exercise {
  final List<int> defaultGapLengths;
  final String statementCode;
  final List<List<String>>? correctAnswers;

  ExerciseSCW({
    required id,
    required difficulty,
    String? statement,
    required this.statementCode,
    required String statementOutput,
    required this.defaultGapLengths,
    String? specificTip,
    this.correctAnswers,
  }) : super(
          type: ExerciseType.SCW,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementOutput: statementOutput,
          specificTip: specificTip,
        );

  factory ExerciseSCW.fromJson(Map<String, dynamic> json) {
    List<dynamic> defaultGapLengths = json['defaultGapLengths'];
    List<int> defaultGapLengthsInt = defaultGapLengths.cast<int>().toList();
    List<dynamic>? correctAnswers = json['correctAnswers'];
    List<List<String>>? correctAnswersList =
        correctAnswers?.map((answer) => List<String>.from(answer)).toList();
    return ExerciseSCW(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      specificTip: json['specificTip'],
      defaultGapLengths: defaultGapLengthsInt,
      statementOutput: json['statementOutput'],
      correctAnswers: correctAnswersList,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'type': type.toString(),
        'statement': statement,
        'statementCode': statementCode,
        'specificTip': specificTip,
        'defaultGapLengths': defaultGapLengths,
        'statementOutput': statementOutput,
        'correctAnswers': correctAnswers,
      };
}
