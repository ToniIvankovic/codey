class Lesson {
  int id;
  List<int> exerciseIds;
  String name;
  String? specificTips;
  bool adaptive;
  int courseId;
  int? exerciseLimit;

  Lesson({
    required this.id,
    required this.exerciseIds,
    required this.name,
    this.specificTips,
    this.adaptive = false,
    required this.courseId,
    this.exerciseLimit,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['privateId'],
      name: json['name'],
      exerciseIds: json['exercises'].cast<int>(),
      specificTips: json['specificTips'],
      adaptive: json['adaptive'] ?? false,
      courseId: json['courseId'],
      exerciseLimit: json['exerciseLimit'],
    );
  }
}
