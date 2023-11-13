class ExercisesResponse {
  ExercisesResponse({
    this.exercises,
  });

  List<Exercise>? exercises;

  factory ExercisesResponse.fromJson(Map<String, dynamic> json) =>
      ExercisesResponse(
        exercises: List<Exercise>.from(
            json["exercises"].map((x) => Exercise.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "exercises": exercises == null ? [] : List<dynamic>.from(exercises!.map((x) => x.toJson())),
      };
}

class Exercise {
  Exercise({
    required this.id,
    required this.type,
    this.statement,
    this.statementCode,
    this.question,
    this.answerOptions,
    this.correctAnswer,
    this.difficulty,
  });

  String id;
  String type;
  String? statement;
  String? statementCode;
  String? question;
  dynamic? answerOptions;
  String? correctAnswer;
  double? difficulty;

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json["_id"],
        type: json["Type"],
        statement: json["Statement"],
        statementCode: json["StatementCode"],
        question: json["Question"],
        answerOptions: json["AnswerOptions"],
        correctAnswer: json["CorrectAnswer"],
        difficulty: json["Difficulty"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "statement": statement,
        "statementCode": statementCode,
        "question": question,
        "answerOptions": answerOptions,
        "correctAnswer": correctAnswer,
        "difficulty": difficulty,
      };

      @override
  String toString() {
    return ("$id, $type, $statement, $statementCode, $question, $answerOptions, $correctAnswer, $difficulty\n");
  }
}
