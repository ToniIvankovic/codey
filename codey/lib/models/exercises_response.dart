import '/models/exercise.dart';

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
