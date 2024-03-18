class LessonGroup {
  final int id;
  final String name;
  final String tips;
  final List<int> lessons;

  LessonGroup({
    required this.id,
    required this.name,
    required this.tips,
    required this.lessons,
  });

  factory LessonGroup.fromJson(Map<String, dynamic> json) {
    return LessonGroup(
      id: json['privateId'],
      name: json['name'],
      tips: json['tips'],
      lessons: json['lessonIds'].cast<int>(),
    );
  }
}
