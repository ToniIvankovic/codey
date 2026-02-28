import 'package:codey/models/entities/lesson.dart';

class LessonCreationDto {
  List<int> exerciseIds;
  String name;
  String? specificTips;
  int courseId;

  LessonCreationDto({
    required this.exerciseIds,
    required this.name,
    this.specificTips,
    required this.courseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exerciseIds,
      'specificTips': specificTips,
      'courseId': courseId,
    };
  }

  factory LessonCreationDto.fromLesson(Lesson lesson) {
    return LessonCreationDto(
      name: lesson.name,
      exerciseIds: lesson.exerciseIds,
      specificTips: lesson.specificTips,
      courseId: lesson.courseId,
    );
  }
}
