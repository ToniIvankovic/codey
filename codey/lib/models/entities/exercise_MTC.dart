// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';
import 'exercise.dart';

class ExerciseMTC extends Exercise {
  List<String> leftItems;
  List<String> rightItems;

  ExerciseMTC({
    required id,
    required difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
    String? imageUrl,
    required this.leftItems,
    required this.rightItems,
    required courseId,
  }) : super(
          type: ExerciseType.MTC,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementOutput: statementOutput,
          specificTip: specificTip,
          imageUrl: imageUrl,
          courseId: courseId,
        );

  factory ExerciseMTC.fromJson(Map<String, dynamic> json) {
    return ExerciseMTC(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementOutput: json['statementOutput'],
      specificTip: json['specificTip'],
      imageUrl: json['imageUrl'],
      leftItems: List<String>.from(json['answerOptionsList'][0]),
      rightItems: List<String>.from(json['answerOptionsList'][1]),
      courseId: json['courseId'],
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
        if (imageUrl != null) 'imageUrl': imageUrl,
        'answerOptionsList': [leftItems, rightItems],
        'courseId': courseId,
      };

  factory ExerciseMTC.fromExercise(ExerciseMTC other) {
    return ExerciseMTC(
      id: other.id,
      difficulty: other.difficulty,
      statement: other.statement,
      statementOutput: other.statementOutput,
      specificTip: other.specificTip,
      imageUrl: other.imageUrl,
      leftItems: other.leftItems,
      rightItems: other.rightItems,
      courseId: other.courseId,
    );
  }
}
