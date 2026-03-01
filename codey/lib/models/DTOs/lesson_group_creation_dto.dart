import 'package:codey/models/entities/lesson_group.dart';

class LessonGroupCreationDto {
  String name;
  String? tips;
  List<int> lessons;
  int order;
  bool adaptive;
  int courseId;

  LessonGroupCreationDto({
    required this.name,
    this.tips,
    this.lessons = const [],
    this.order = 0,
    this.adaptive = false,
    required this.courseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tips': tips,
      'lessons': lessons,
      'order': order,
      'adaptive': adaptive,
      'courseId': courseId,
    };
  }

  factory LessonGroupCreationDto.fromLessonGroup(LessonGroup lessonGroup) {
    return LessonGroupCreationDto(
      name: lessonGroup.name,
      tips: lessonGroup.tips,
      lessons: lessonGroup.lessons,
      order: lessonGroup.order,
      adaptive: lessonGroup.adaptive,
      courseId: lessonGroup.courseId,
    );
  }
}
