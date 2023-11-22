class LessonGroup {
  final int id;
  final String name;
  final String tips;

  LessonGroup({
    required this.id,
    required this.name,
    required this.tips,
  });

  factory LessonGroup.fromJson(Map<String, dynamic> json) {
    return LessonGroup(
      id: json['id'],
      name: json['name'],
      tips: json['tips'],
    );
  }
}
