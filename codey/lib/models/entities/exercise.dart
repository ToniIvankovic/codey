import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:codey/models/entities/exercise_statistics.dart';
import 'package:codey/models/entities/exercise_type.dart';

abstract class Exercise {
  final int id;
  final int difficulty;
  final ExerciseType type;
  final String? statement;
  final String? specificTip;
  final String? statementOutput;
  ExerciseStatistics? statistics;

  Exercise({
    required this.id,
    required this.difficulty,
    required this.type,
    this.statement,
    this.specificTip,
    this.statementOutput,
    this.statistics,
  });
  
  factory Exercise.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'MC':
        return ExerciseMC.fromJson(json);
      case 'SA':
        return ExerciseSA.fromJson(json);
      case 'LA':
        return ExerciseLA.fromJson(json);
      case 'SCW':
        return ExerciseSCW.fromJson(json);
      default:
        throw Exception('Invalid exercise type');
    }
  }

  Map<String, dynamic> toJson();
}
