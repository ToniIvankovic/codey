class EndReport {
  int lessonId;
  int lessonGroupId;
  int correctAnswers;
  int totalAnswers;
  int totalExercises;
  final DateTime _startTime = DateTime.now();
  late final List<MapEntry<int, bool>>? answersReport;

  EndReport({
    required this.lessonId,
    required this.lessonGroupId,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.totalExercises,
  }) {
    answersReport = [];
  }

  double get accuracy => correctAnswers / totalAnswers;
  Duration get duration => DateTime.now().difference(_startTime);

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lessonGroupId': lessonGroupId,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'totalExercises': totalExercises,
      'accuracy': accuracy,
      'durationMiliseconds': duration.inMilliseconds,
      //convert to list<keyValuePair<int, bool>>
      'answersReport': answersReport!.map((entry) => {
            'key': entry.key,
            'value': entry.value,
          }).toList(),
    };
  }
}
