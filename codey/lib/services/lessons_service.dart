import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import '/repositories/lessons_repository.dart';

abstract class LessonsService {
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup);
  Future<List<Lesson>> getAllLessons();
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds);
  void updateLesson(Lesson lesson);
}

class LessonsServiceV1 implements LessonsService {
  final LessonsRepository _lessonsRepository;

  LessonsServiceV1(this._lessonsRepository);

  @override
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup) {
    return _lessonsRepository.getLessonsForGroup(lessonGroup);
  }

  @override
  Future<List<Lesson>> getAllLessons() {
    return _lessonsRepository.getAllLessons();
  }

  @override
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds) {
    return _lessonsRepository.getLessonsByIds(lessonIds);
  }

  @override
  void updateLesson(Lesson lesson) {
    _lessonsRepository.invalidateCache(lesson);
    //TODO: update on server
  }
}
