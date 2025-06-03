import 'package:equatable/equatable.dart';
import 'package:university_journal/bloc/journal/group.dart';
import '../user/user.dart';

class Course extends Equatable {
  final int id;
  final String name;
  final List<Group> groups;
  final List<MyUser> teachers;

  const Course({required this.id, required this.name, required this.groups, required this.teachers});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      groups: (json['groups'] as List<dynamic>)
          .map((g) => Group.fromJson(g as Map<String, dynamic>))
          .toList(),
      teachers: (json['teachers'] as List<dynamic>)
          .map((e) => MyUser.fromJson(e))
          .toList(),
    );
  }

  @override
  List<Object> get props => [id, name];
}
