// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';
import 'exercise.dart';

class ExerciseORC extends Exercise {
  List<String> answerOptions; // lines in correct order

  ExerciseORC({
    required id,
    required difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
    String? imageUrl,
    required this.answerOptions,
    required courseId,
  }) : super(
          type: ExerciseType.ORC,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementOutput: statementOutput,
          specificTip: specificTip,
          imageUrl: imageUrl,
          courseId: courseId,
        );

  factory ExerciseORC.fromJson(Map<String, dynamic> json) {
    return ExerciseORC(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementOutput: json['statementOutput'],
      specificTip: json['specificTip'],
      imageUrl: json['imageUrl'],
      answerOptions: List<String>.from(json['answerOptionsList'][0]),
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
        'answerOptionsList': [answerOptions],
        'courseId': courseId,
      };

  factory ExerciseORC.fromExercise(ExerciseORC other) {
    return ExerciseORC(
      id: other.id,
      difficulty: other.difficulty,
      statement: other.statement,
      statementOutput: other.statementOutput,
      specificTip: other.specificTip,
      imageUrl: other.imageUrl,
      answerOptions: other.answerOptions,
      courseId: other.courseId,
    );
  }
}
