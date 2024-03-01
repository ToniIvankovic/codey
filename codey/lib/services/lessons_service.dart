import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import '/repositories/lessons_repository.dart';

abstract class LessonsService {
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup);
}

class LessonsServiceV1 implements LessonsService {
  final LessonsRepository _lessonsRepository;

  LessonsServiceV1(this._lessonsRepository);

  @override
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup) {
    return _lessonsRepository.getLessonsForGroup(lessonGroup);
  }
}