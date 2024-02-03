class Lesson {
  int id;
  String lessonGroupId;
  List<String> exerciseIds;
  String name;
  String? specificTips;

  Lesson({
    required this.id,
    required this.lessonGroupId,
    required this.exerciseIds,
    required this.name,
    this.specificTips,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['privateId'],
      lessonGroupId: json['lessonGroupId'].toString(),
      name: json['name'],
      exerciseIds: json['exercises'].cast<String>(),
      specificTips: json['specificTips'],
    );
  }
}
