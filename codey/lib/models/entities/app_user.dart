import 'package:codey/models/entities/quest.dart';

class AppUser {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String email;
  final int? highestLessonId;
  final int? highestLessonGroupId;
  final int? nextLessonId;
  final int? nextLessonGroupId;
  final List<String> roles;
  final int totalXp;
  final int? classId;
  final Set<Quest> quests;
  final int streak;
  final bool didLessonToday;
  final bool justUpdatedStreak;
  final int highestStreak;

  AppUser({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    required this.email,
    this.highestLessonId,
    this.highestLessonGroupId,
    required this.nextLessonId,
    required this.nextLessonGroupId,
    required this.roles,
    required this.totalXp,
    this.classId,
    required this.quests,
    required this.streak,
    required this.didLessonToday,
    required this.justUpdatedStreak,
    required this.highestStreak,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      email: json['email'],
      highestLessonId: json['highestLessonId'],
      highestLessonGroupId: json['highestLessonGroupId'],
      nextLessonId: json['nextLessonId'],
      nextLessonGroupId: json['nextLessonGroupId'],
      roles: (json['roles'] as List<dynamic>)
          .map((role) => role.toString())
          .toList(),
      totalXp: json['totalXP'],
      classId: json['classId'],
      quests: (json['dailyQuests'] as List<dynamic>)
          .map((quest) => Quest.fromJson(quest))
          .toSet(),
      streak: json['currentStreak'],
      didLessonToday: json['didLessonToday'],
      justUpdatedStreak: json['justUpdatedStreak'],
      highestStreak: json['highestStreak'],
    );
  }
}
