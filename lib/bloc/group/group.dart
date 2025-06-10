import 'dart:convert';

class Group {
  final int id;
  final String name;
  final int facultyId;
  final String facultyName;
  final int courseId;
  final String courseName;

  Group({
    required this.id,
    required this.name,
    required this.facultyId,
    required this.courseId,
    required this.facultyName,
    required this.courseName,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['group_name'],
      facultyId: json['faculty']['id'],
      courseId: json['course']['id'],
      facultyName: json['faculty']['name'],
      courseName: json['course']['name'],
    );
  }

  @override
  String toString() => '$id: $name';
}
