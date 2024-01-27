// ignore_for_file: constant_identifier_names

class ExerciseType {
  static ExerciseType MC = ExerciseType("MC");
  static ExerciseType SA = ExerciseType("SA");
  static ExerciseType LA = ExerciseType("LA");
  // static const String SA = "SA";
  // static const String LA = "LA";

  String type;
  ExerciseType(this.type);
}
