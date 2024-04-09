class AppUser {
  final String email;
  final int? highestLessonId;
  final int? highestLessonGroupId;
  final int? nextLessonId;
  final int? nextLessonGroupId;
  final List<String> roles;
  final int totalXp;

  AppUser({
    required this.email,
    this.highestLessonId,
    this.highestLessonGroupId,
    required this.nextLessonId,
    required this.nextLessonGroupId,
    required this.roles,
    required this.totalXp,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      highestLessonId: json['highestLessonId'],
      highestLessonGroupId: json['highestLessonGroupId'],
      nextLessonId: json['nextLessonId'],
      nextLessonGroupId: json['nextLessonGroupId'],
      roles: (json['roles'] as List<dynamic>).map((role) => role.toString()).toList(),
      totalXp: json['totalXP'],
    );
  }
}
