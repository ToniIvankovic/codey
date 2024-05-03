class ExerciseStatistics {
  int exerciseId;
  double suggestedDifficulty;
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
      suggestedDifficulty: json['suggestedDifficulty'] + 0.0,
      averageDifficultyCorrect:
          double.tryParse(json['averageDifficultyCorrect'].toString()),
      averageDifficultyIncorrect:
          double.tryParse(json['averageDifficultyIncorrect'].toString()),
    );
  }
}
