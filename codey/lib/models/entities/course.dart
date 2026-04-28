class Course {
  final int id;
  final String name;
  final String shortName;
  final String description;
  final int? defaultExerciseLimit;
  final bool scwTextWrap;

  Course({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    this.defaultExerciseLimit,
    this.scwTextWrap = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'],
      description: json['description'],
      defaultExerciseLimit: json['defaultExerciseLimit'],
      scwTextWrap: json['scwTextWrap'] ?? false,
    );
  }
}
