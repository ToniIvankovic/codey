import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_type.dart';

abstract class Exercise {
  final int id;
  final int difficulty;
  final ExerciseType type;
  final String? statement;
  final String? statementCode;
  final String? question;
  final String? specificTip;

  Exercise({
    required this.id,
    required this.difficulty,
    required this.type,
    this.statement,
    this.statementCode,
    this.question,
    this.specificTip,
  });
  
  factory Exercise.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'MC':
        return ExerciseMC.fromJson(json);
      case 'SA':
        return ExerciseSA.fromJson(json);
      case 'LA':
        return ExerciseLA.fromJson(json);
      default:
        throw Exception('Invalid exercise type');
    }
  }

  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'difficulty': difficulty,
  //       'type': type.toString().split('.').last,
  //       'statement': statement,
  //       'statementCode': statementCode,
  //       'question': question,
  //       'specificTip': specificTip,
  //     };
}
