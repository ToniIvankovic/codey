class ExerciseStatistics {
  int exerciseId;
  int suggestedDifficulty;
  double? averageDifficultyCorrect;
  double? averageDifficultyIncorrect;

  ExerciseStatistics({
    required this.exerciseId,
    required this.suggestedDifficulty,
    required this.averageDifficultyCorrect,
    required this.averageDifficultyIncorrect,
  });

  factory ExerciseStatistics.fromJson(Map<String, dynamic> json) {
    return ExerciseStatistics(
      exerciseId: json['exerciseId'],
      suggestedDifficulty: json['suggestedDifficulty'],
      averageDifficultyCorrect:
          double.tryParse(json['averageDifficultyCorrect'].toString()),
      averageDifficultyIncorrect:
          double.tryParse(json['averageDifficultyIncorrect'].toString()),
    );
  }
}
