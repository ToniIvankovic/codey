import 'dart:convert';

import 'package:codey/models/DTOs/lesson_group_creation_dto.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/repositories/lesson_groups_repository.dart';
import 'package:http/http.dart' as http;

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
  static Uri _apiUriSingleLG(lessonGroup) =>
      Uri.parse('${dotenv.env["API_BASE"]}/lessonGroups/${lessonGroup.id}');
  static final Uri _apiUriBase =
      Uri.parse('${dotenv.env["API_BASE"]}/lessonGroups');
  static Uri _apiUriDeleteLG(int id) =>
      Uri.parse('${dotenv.env["API_BASE"]}/lessonGroups/$id');
  final LessonGroupsRepository _lessonGroupsRepository;
  final http.Client _authenticatedClient;
  final UserService _userService;

  LessonGroupsServiceV1(this._lessonGroupsRepository, this._authenticatedClient,
      this._userService);

  @override
  Future<List<LessonGroup>> getAllLessonGroups() {
    return _lessonGroupsRepository.getAllLessonGroups();
  }

  @override
  Future<LessonGroup> getLessonGroupById(int id) {
    return _lessonGroupsRepository.getLessonGroupById(id);
  }

  @override
  Future<LessonGroup> updateLessonGroup(LessonGroup lessonGroup) async {
    _lessonGroupsRepository.invalidateCache();
    var response = await _authenticatedClient.put(_apiUriSingleLG(lessonGroup),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(LessonGroupCreationDto(
          name: lessonGroup.name,
          tips: lessonGroup.tips,
          lessons: lessonGroup.lessons,
          order: lessonGroup.order,
          adaptive: lessonGroup.adaptive,
          courseId: lessonGroup.courseId,
        ).toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to update lesson group: ${lessonGroup.id}, '
          'Error ${response.statusCode}');
    }
    return LessonGroup.fromJson(jsonDecode(response.body));
  }

  @override
  void reorderLessonGroups(List<LessonGroup> lessonGroups) async {
    for (var i = 0; i < lessonGroups.length; i++) {
      lessonGroups[i].order = i + 1;
    }
    _lessonGroupsRepository.invalidateCache();
    var response = await _authenticatedClient.put(_apiUriBase,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(lessonGroups
            .map((lessonGroup) =>
                {"id": lessonGroup.id, "order": lessonGroup.order})
            .toList()));
    if (response.statusCode != 200) {
      throw Exception('Failed to update lesson group order, '
          'Error ${response.statusCode}');
    }
  }

  @override
  Future<LessonGroup> createLessonGroup({
    required String name,
    String? tips,
    List<int>? lessons,
    required bool adaptive,
  }) async {
    _lessonGroupsRepository.invalidateCache();
    int courseId = (await _userService.userStream.first).course.id;
    var dto = LessonGroupCreationDto(
      name: name,
      tips: tips,
      lessons: lessons ?? [],
      adaptive: adaptive,
      courseId: courseId,
    );
    var response = await _authenticatedClient.post(_apiUriBase,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(dto.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to create lesson group, '
          'Error ${response.statusCode}');
    }

    return LessonGroup.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> deleteLessonGroup(int id) async {
    _lessonGroupsRepository.invalidateCache();
    var response = await _authenticatedClient.delete(_apiUriDeleteLG(id));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete lesson group: $id, '
          'Error ${response.statusCode}');
    }
    return;
  }
}
