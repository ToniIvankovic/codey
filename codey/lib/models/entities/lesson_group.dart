class LessonGroup {
  final int id;
  String name;
  String? tips;
  List<int> lessons;
  int order;
  bool adaptive;
  int courseId;

  LessonGroup({
    required this.id,
    required this.name,
    this.tips,
    required this.lessons,
    required this.order,
    this.adaptive = false,
    required this.courseId,
  });

  factory LessonGroup.fromJson(Map<String, dynamic> json) {
    return LessonGroup(
      id: json['privateId'],
      name: json['name'],
      tips: json['tips'],
      lessons: json['lessonIds'].cast<int>(),
      order: json['order'],
      adaptive: json['adaptive'] ?? false,
      courseId: json['courseId'],
    );
  }

  toJson() {
    return {
      'privateId': id,
      'name': name,
      'tips': tips,
      'lessonIds': lessons,
      'order': order,
      'adaptive': adaptive,
      'courseId': courseId,
    };
  }
}
