class EndReport {
  int lessonId;
  int lessonGroupId;
  int correctAnswers;
  int totalAnswers;
  int totalExercises;
  final DateTime _startTime = DateTime.now();

  EndReport(this.lessonId, this.lessonGroupId, this.correctAnswers, this.totalAnswers,
      this.totalExercises);

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
      'duration': duration.inMilliseconds,
    };
  }
}
