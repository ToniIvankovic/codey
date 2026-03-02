import 'package:codey/models/entities/lesson_group.dart';

class LessonGroupCreationDto {
  String name;
  String? tips;
  List<int> lessons;
  bool adaptive;
  int courseId;

  LessonGroupCreationDto({
    required this.name,
    this.tips,
    this.lessons = const [],
    this.adaptive = false,
    required this.courseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tips': tips,
      'lessons': lessons,
      'adaptive': adaptive,
      'courseId': courseId,
    };
  }

  factory LessonGroupCreationDto.fromLessonGroup(LessonGroup lessonGroup) {
    return LessonGroupCreationDto(
      name: lessonGroup.name,
      tips: lessonGroup.tips,
      lessons: lessonGroup.lessons,
      adaptive: lessonGroup.adaptive,
      courseId: lessonGroup.courseId,
    );
  }
}
