import 'package:equatable/equatable.dart';

import '../../user/models/user.dart';

class Group extends Equatable{
  final int id;
  final String name;
  final int facultyId;
  final String facultyName;
  final int courseId;
  final String courseName;
  final List<MyUser> students;

  Group({
    required this.id,
    required this.name,
    required this.facultyId,
    required this.courseId,
    required this.facultyName,
    required this.courseName,
    required this.students,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      facultyId: json['faculty']['id'],
      courseId: json['course']['id'],
      facultyName: json['faculty']['name'],
      courseName: json['course']['name'],
      students: (json['students'] as List)
          .map((e) => MyUser.fromGroupJson(e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id];
}
