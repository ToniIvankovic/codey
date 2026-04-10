import 'package:codey/models/entities/lesson.dart';

class LessonCreationDto {
  List<int> exerciseIds;
  String name;
  String? specificTips;
  int courseId;
  int? exerciseLimit;

  LessonCreationDto({
    required this.exerciseIds,
    required this.name,
    this.specificTips,
    required this.courseId,
    this.exerciseLimit,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'exercises': exerciseIds,
      'specificTips': specificTips,
      'courseId': courseId,
    };
    if (exerciseLimit != null) map['exerciseLimit'] = exerciseLimit;
    return map;
  }

  factory LessonCreationDto.fromLesson(Lesson lesson) {
    return LessonCreationDto(
      name: lesson.name,
      exerciseIds: lesson.exerciseIds,
      specificTips: lesson.specificTips,
      courseId: lesson.courseId,
      exerciseLimit: lesson.exerciseLimit,
    );
  }
}
