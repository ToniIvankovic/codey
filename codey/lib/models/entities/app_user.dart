class AppUser {
  final String email;
  final int? highestLessonId;
  final int? highestLessonGroupId;
  final int nextLessonId;
  final int nextLessonGroupId;

  AppUser({
    required this.email,
    this.highestLessonId,
    this.highestLessonGroupId,
    required this.nextLessonId,
    required this.nextLessonGroupId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      highestLessonId: json['lastLessonId'],
      highestLessonGroupId: json['lastLessonGroupId'],
      nextLessonId: json['nextLessonId'],
      nextLessonGroupId: json['nextLessonGroupId'],
    );
  }
}
