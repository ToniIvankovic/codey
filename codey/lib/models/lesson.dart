import 'package:codey/models/exercise.dart';

class Lesson {
  String id;
  String lessonGroupId;
  List<String> exerciseIds;
  String? specificTips;

  Lesson({
    required this.id,
    required this.lessonGroupId,
    required this.exerciseIds,
    this.specificTips,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      lessonGroupId: json['lessonGroup'],
      exerciseIds: json['exercises'].cast<String>(),
      specificTips: json['specificTips'],
    );
  }
}
