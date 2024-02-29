import 'package:codey/models/entities/lesson_group.dart';
import '/repositories/lesson_groups_repository.dart';

abstract class LessonGroupsService {
  Future<List<LessonGroup>> getAllLessonGroups();
}

class LessonGroupsServiceV1 implements LessonGroupsService {
  final LessonGroupsRepository _lessonGroupsRepository;

  LessonGroupsServiceV1(this._lessonGroupsRepository);

  @override
  Future<List<LessonGroup>> getAllLessonGroups() {
    return _lessonGroupsRepository.getAllLessonGroups();
  }
}