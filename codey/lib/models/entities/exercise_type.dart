// ignore_for_file: non_constant_identifier_names

class ExerciseType {
  static ExerciseType MC = ExerciseType._("MC");
  static ExerciseType SA = ExerciseType._("SA");
  static ExerciseType LA = ExerciseType._("LA");
  static ExerciseType SCW = ExerciseType._("SCW");
  static ExerciseType ORC = ExerciseType._("ORC");
  static ExerciseType MTC = ExerciseType._("MTC");
  static List<ExerciseType> values = [MC, SA, LA, SCW, ORC, MTC];

  String type;
  ExerciseType._(this.type);

  @override
  String toString() {
    return type;
  }
}
