import 'package:codey/models/entities/lesson.dart';
import '/repositories/lessons_repository.dart';

abstract class LessonsService {
  Future<List<Lesson>> getLessonsForGroup(String lessonGroup);
}

class LessonsServiceV1 implements LessonsService {
  final LessonsRepository _lessonsRepository;

  LessonsServiceV1(this._lessonsRepository);

  @override
  Future<List<Lesson>> getLessonsForGroup(String lessonGroup) {
    return _lessonsRepository.getLessonsForGroup(lessonGroup);
  }
}