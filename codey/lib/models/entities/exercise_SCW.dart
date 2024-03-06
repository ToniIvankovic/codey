// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';

import 'exercise.dart';

class ExerciseSCW extends Exercise {
  ExerciseSCW({
    required id,
    required difficulty,
    String? statement,
    required String statementCode,
    required List<int> defaultGapLengths,
    required List<int> defaultGapLines,
    String? statementOutput,
    String? specificTip,
  }) : super(
          type: ExerciseType.SA,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementCode: statementCode,
          defaultGapLengths: defaultGapLengths,
          defaultGapLines: defaultGapLines,
          statementOutput: statementOutput,
          specificTip: specificTip,
        );

  factory ExerciseSCW.fromJson(Map<String, dynamic> json) {
    List<dynamic> defaultGapLengths = json['defaultGapLengths'];
    List<int> defaultGapLengthsInt = defaultGapLengths.cast<int>().toList();
    List<dynamic> defaultGapLines = json['defaultGapLines'];
    List<int> defaultGapLinesInt = defaultGapLines.cast<int>().toList();
    return ExerciseSCW(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementCode: json['statementCode'],
      specificTip: json['specificTip'],
      defaultGapLengths: defaultGapLengthsInt,
      defaultGapLines: defaultGapLinesInt,
      statementOutput: json['statementOutput'],
    );
  }
}