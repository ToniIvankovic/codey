class EndReport {
  String lessonId;
  int correctAnswers;
  int totalAnswers;
  int totalExercises;
  final DateTime _startTime;

  EndReport(this.lessonId, this.correctAnswers, this.totalAnswers,
      this.totalExercises, this._startTime);

  double get accuracy => correctAnswers / totalAnswers;
  Duration get duration => DateTime.now().difference(_startTime);

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'totalExercises': totalExercises,
      'accuracy': accuracy,
      'duration': duration.inMilliseconds,
    };
  }
}
