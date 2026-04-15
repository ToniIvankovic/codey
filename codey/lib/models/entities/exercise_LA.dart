// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_type.dart';
import 'exercise.dart';

class ExerciseLA extends Exercise {
  List<String>? answerOptions;
  List<String> correctAnswers = [];

  ExerciseLA({
    required id,
    required difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
    String? imageUrl,
    this.answerOptions,
    required this.correctAnswers,
    required courseId,
  }) : super(
          type: ExerciseType.LA,
          id: id,
          difficulty: difficulty,
          statement: statement,
          statementOutput: statementOutput,
          specificTip: specificTip,
          imageUrl: imageUrl,
          courseId: courseId,
        );

  factory ExerciseLA.fromJson(Map<String, dynamic> json) {
    final List<String>? options = json['answerOptionsList'] != null
        ? List<String>.from(json['answerOptionsList'][0])
        : null;
    return ExerciseLA(
      id: json['privateId'],
      difficulty: json['difficulty'],
      statement: json['statement'],
      statementOutput: json['statementOutput'],
      specificTip: json['specificTip'],
      imageUrl: json['imageUrl'],
      answerOptions: options,
      correctAnswers: json['correctAnswers'] != null
          ? List<String>.from(json['correctAnswers'])
          : [],
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
        'answerOptionsList': answerOptions != null ? [answerOptions] : null,
        'correctAnswers': correctAnswers,
        'courseId': courseId,
      };

  factory ExerciseLA.fromExercise(ExerciseLA other) {
    return ExerciseLA(
      id: other.id,
      difficulty: other.difficulty,
      statement: other.statement,
      statementOutput: other.statementOutput,
      specificTip: other.specificTip,
      imageUrl: other.imageUrl,
      answerOptions: other.answerOptions,
      correctAnswers: other.correctAnswers,
      courseId: other.courseId,
    );
  }
}
