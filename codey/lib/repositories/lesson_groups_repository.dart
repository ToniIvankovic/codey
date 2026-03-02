import 'dart:convert';

import 'package:codey/models/DTOs/lesson_group_creation_dto.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

abstract class LessonGroupsRepository {
  Future<List<LessonGroup>> getAllLessonGroups();
  Future<LessonGroup> getLessonGroupById(int id);
  Future<LessonGroup> updateLessonGroup(LessonGroup lessonGroup);
  Future<void> reorderLessonGroups(List<LessonGroup> lessonGroups);
  Future<LessonGroup> createLessonGroup({
    required String name,
    String? tips,
    List<int>? lessons,
    required bool adaptive,
  });
  Future<void> deleteLessonGroup(int id);
  void invalidateCache() {}
}

class LessonGroupsRepository1 implements LessonGroupsRepository {
  final String _apiUrl = '${dotenv.env["API_BASE"]}/lessonGroups';
  final http.Client _authenticatedClient;
  final UserService _userService;
  List<LessonGroup>? _cache;

  LessonGroupsRepository1(
    this._authenticatedClient,
    this._userService,
    SessionService sessionService,
  ) {
    Rx.merge([
      _userService.courseChanged,
      sessionService.logoutStream,
    ]).listen((_) => invalidateCache());
  }

  @override
  Future<List<LessonGroup>> getAllLessonGroups() {
    if (_cache == null) {
      return _fetchLessonGroups();
    }
    return Future.value(_cache!);
  }

  @override
  Future<LessonGroup> getLessonGroupById(int id) async {
    if (_cache?.where((element) => element.id == id).isNotEmpty ?? false) {
      return _cache!.firstWhere((element) => element.id == id);
    }

    final response = await _authenticatedClient.get(Uri.parse(_apiUrl));
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException(
              'Unauthorized retrieval of lesson groups');
        default:
          throw Exception('Failed to fetch lesson groups, '
              'Error ${response.statusCode}');
      }
    }

    final List<dynamic> data = json.decode(response.body);
    final LessonGroup lessonGroup =
        data.map((item) => LessonGroup.fromJson(item)).first;
    return lessonGroup;
  }

  @override
  Future<LessonGroup> updateLessonGroup(LessonGroup lessonGroup) async {
    invalidateCache();
    final response = await _authenticatedClient.put(
        Uri.parse('$_apiUrl/${lessonGroup.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(LessonGroupCreationDto.fromLessonGroup(lessonGroup).toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to update lesson group: ${lessonGroup.id}, '
          'Error ${response.statusCode}');
    }
    return LessonGroup.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> reorderLessonGroups(List<LessonGroup> lessonGroups) async {
    for (var i = 0; i < lessonGroups.length; i++) {
      lessonGroups[i].order = i + 1;
    }
    invalidateCache();
    final response = await _authenticatedClient.put(Uri.parse(_apiUrl),
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
    invalidateCache();
    int courseId = (await _userService.userStream.first).course.id;
    var dto = LessonGroupCreationDto(
      name: name,
      tips: tips,
      lessons: lessons ?? [],
      adaptive: adaptive,
      courseId: courseId,
    );
    final response = await _authenticatedClient.post(Uri.parse(_apiUrl),
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
    invalidateCache();
    final response = await _authenticatedClient
        .delete(Uri.parse('$_apiUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete lesson group: $id, '
          'Error ${response.statusCode}');
    }
  }

  Future<List<LessonGroup>> _fetchLessonGroups() async {
    final response = await _authenticatedClient.get(Uri.parse(_apiUrl));

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException(
              'Unauthorized retrieval of lesson groups');
        default:
          throw Exception('Failed to fetch lesson groups, '
              'Error ${response.statusCode}');
      }
    }

    final List<dynamic> data = json.decode(response.body);
    final List<LessonGroup> lessonGroups =
        data.map((item) => LessonGroup.fromJson(item)).toList();
    _cache = lessonGroups;
    return lessonGroups;
  }

  @override
  void invalidateCache() {
    _cache = null;
  }
}
