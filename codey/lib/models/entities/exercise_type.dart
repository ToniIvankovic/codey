// ignore_for_file: non_constant_identifier_names

class ExerciseType {
  static ExerciseType MC = ExerciseType._("MC");
  static ExerciseType SA = ExerciseType._("SA");
  static ExerciseType LA = ExerciseType._("LA");
  static ExerciseType SCW = ExerciseType._("SCW");
  static List<ExerciseType> values = [MC, SA, LA, SCW];

  String type;
  ExerciseType._(this.type);

  @override
  String toString() {
    return type;
  }
}
