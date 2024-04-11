import 'package:codey/models/entities/app_user.dart';

class Leaderboard {
  final int classId;
  final List<AppUser> students;

  Leaderboard({
    required this.classId,
    required this.students,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      classId: json['classId'],
      students: (json['students'] as List)
          .map((student) => AppUser.fromJson(student))
          .toList(),
    );
  }
}
