import 'package:codey/models/exercise_type.dart';

class Exercise {
  final int id;
  final double difficulty;
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
    return Exercise(
      id: json['id'],
      difficulty: (json['difficulty']).toDouble(),
      type: ExerciseType.values
          .firstWhere((e) => e.toString() == 'ExerciseType.' + json['type']),
      statement: json['statement'],
      statementCode: json['statementCode'],
      question: json['question'],
      specificTip: json['specificTip'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'type': type.toString().split('.').last,
        'statement': statement,
        'statementCode': statementCode,
        'question': question,
        'specificTip': specificTip,
      };
}
