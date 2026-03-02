import 'package:codey/models/entities/lesson_group.dart';
import '/repositories/lesson_groups_repository.dart';

abstract class LessonGroupsService {
  Future<List<LessonGroup>> getAllLessonGroups();
  Future<LessonGroup> getLessonGroupById(int id);
  Future<LessonGroup> updateLessonGroup(LessonGroup lessonGroup);
  void reorderLessonGroups(List<LessonGroup> list);
  Future<LessonGroup> createLessonGroup({
    required String name,
    String? tips,
    List<int>? lessons,
    required bool adaptive,
  });
  Future<void> deleteLessonGroup(int id);
}

class LessonGroupsServiceV1 implements LessonGroupsService {
  final LessonGroupsRepository _lessonGroupsRepository;

  LessonGroupsServiceV1(this._lessonGroupsRepository);

  @override
  Future<List<LessonGroup>> getAllLessonGroups() {
    return _lessonGroupsRepository.getAllLessonGroups();
  }

  @override
  Future<LessonGroup> getLessonGroupById(int id) {
    return _lessonGroupsRepository.getLessonGroupById(id);
  }

  @override
  Future<LessonGroup> updateLessonGroup(LessonGroup lessonGroup) {
    return _lessonGroupsRepository.updateLessonGroup(lessonGroup);
  }

  @override
  void reorderLessonGroups(List<LessonGroup> lessonGroups) {
    _lessonGroupsRepository.reorderLessonGroups(lessonGroups);
  }

  @override
  Future<LessonGroup> createLessonGroup({
    required String name,
    String? tips,
    List<int>? lessons,
    required bool adaptive,
  }) {
    return _lessonGroupsRepository.createLessonGroup(
      name: name,
      tips: tips,
      lessons: lessons,
      adaptive: adaptive,
    );
  }

  @override
  Future<void> deleteLessonGroup(int id) {
    return _lessonGroupsRepository.deleteLessonGroup(id);
  }
}
