import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import '/repositories/lessons_repository.dart';

abstract class LessonsService {
  Future<List<Lesson>> getLessonsForGroup(LessonGroup lessonGroup);
  Future<List<Lesson>> getAllLessons();
  Future<List<Lesson>> getLessonsByIds(List<int> lessonIds);
  Future<Lesson> updateLesson(int id, String name, String? tips, List<int> exerciseIds);
  void deleteLesson(Lesson lesson);
  Future<Lesson> createLesson(String name, String? tips, List<int> exerciseIds);
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
  Future<Lesson> updateLesson(int id, String name, String? tips, List<int> exerciseIds) async {
    return await _lessonsRepository.updateLesson(id, name, tips, exerciseIds);
  }

  @override
  void deleteLesson(Lesson lesson) {
    _lessonsRepository.invalidateCache(lesson.id);
    _lessonsRepository.deleteLesson(lesson);
  }

  @override
  Future<Lesson> createLesson(
      String name, String? tips, List<int> exerciseIds) async {
    final lesson =
        await _lessonsRepository.createLesson(name, tips, exerciseIds);
    return lesson;
  }
}
