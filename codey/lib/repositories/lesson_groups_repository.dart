import 'dart:convert';

import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class LessonGroupsRepository {
  Future<List<LessonGroup>> getAllLessonGroups();
}

class LessonGroupsRepository1 implements LessonGroupsRepository {
  final String _apiUrl = '${dotenv.env["API_BASE"]}/lessonGroups';
  List<LessonGroup>? _lessonGroupsCache;
  final http.Client _authenticatedClient;

  LessonGroupsRepository1(this._authenticatedClient);

  @override
  Future<List<LessonGroup>> getAllLessonGroups() {
    if (_lessonGroupsCache == null) {
      return _fetchLessonGroups();
    }
    return Future.value(_lessonGroupsCache!);
  }

  Future<List<LessonGroup>> _fetchLessonGroups() async {
    final response = await _authenticatedClient.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<LessonGroup> lessonGroups =
          data.map((item) => LessonGroup.fromJson(item)).toList();
      _lessonGroupsCache = lessonGroups;
      return lessonGroups;
    } else {
      switch (response.statusCode) {
        case 401:
          throw UnauthenticatedException(
              'Unauthorized retrieval of lesson groups');
        default:
          throw Exception('Failed to fetch lesson groups, '
              'Error ${response.statusCode}');
      }
    }
  }
}
