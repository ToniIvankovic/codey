import 'dart:convert';

import 'package:codey/models/entities/lesson_group.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/repositories/lesson_groups_repository.dart';
import 'package:http/http.dart' as http;

abstract class LessonGroupsService {
  Future<List<LessonGroup>> getAllLessonGroups();

  void updateLessonGroup(LessonGroup lessonGroup) {}
}

class LessonGroupsServiceV1 implements LessonGroupsService {
  static Uri _apiUri(lessonGroup) =>
      Uri.parse('${dotenv.env["API_BASE"]}/lessonGroups/${lessonGroup.id}');
  final LessonGroupsRepository _lessonGroupsRepository;
  final http.Client _authenticatedClient;

  LessonGroupsServiceV1(
      this._lessonGroupsRepository, this._authenticatedClient);

  @override
  Future<List<LessonGroup>> getAllLessonGroups() {
    return _lessonGroupsRepository.getAllLessonGroups();
  }

  @override
  void updateLessonGroup(LessonGroup lessonGroup) async {
    _lessonGroupsRepository.invalidateCache();
    var response = await _authenticatedClient.put(_apiUri(lessonGroup),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "name": lessonGroup.name,
          "tips": lessonGroup.tips,
          "lessons": lessonGroup.lessons,
          "order": lessonGroup.order
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to update lesson group: ${lessonGroup.id}, '
          'Error ${response.statusCode}');
    }
  }
}
