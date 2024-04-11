class Class {
  String name;
  int id;
  List<String> studentEmails;

  Class({
    required this.name,
    required this.id,
    required this.studentEmails,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'privateId': id,
      'students': studentEmails,
    };
  }

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      name: json['name'],
      id: json['privateId'],
      studentEmails: json['students'].cast<String>(),
    );
  }
}
