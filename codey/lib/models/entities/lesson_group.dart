class LessonGroup {
  final int id;
  String name;
  String tips;
  List<int> lessons;
  int order;

  LessonGroup({
    required this.id,
    required this.name,
    required this.tips,
    required this.lessons,
    required this.order,
  });

  factory LessonGroup.fromJson(Map<String, dynamic> json) {
    return LessonGroup(
      id: json['privateId'],
      name: json['name'],
      tips: json['tips'],
      lessons: json['lessonIds'].cast<int>(),
      order: json['order'],
    );
  }

  toJson() {
    return {
      'privateId': id,
      'name': name,
      'tips': tips,
      'lessonIds': lessons,
      'order': order,
    };
  }
}
