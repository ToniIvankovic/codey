import 'package:codey/models/entities/app_user.dart';

class Class {
  String name;
  Object id; //TODO determine type
  List<AppUser> students;

  Class({
    required this.name,
    required this.id,
    required this.students,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'students': students,
    };
  }

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      name: json['name'],
      id: json['id'],
      students: json['students'],
    );
  }
}
