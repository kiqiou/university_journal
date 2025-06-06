import 'package:equatable/equatable.dart';

import '../discipline/discipline.dart';

class MyUser extends Equatable {
  final int id;
  final String username;
  final String role;
  final String? bio;
  final String? position;
  final int? groupId;
  final List<Discipline> disciplines;

  const MyUser({
    required this.id,
    required this.username,
    required this.role,
    this.bio,
    this.position,
    this.groupId,
    this.disciplines = const [],
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('user') ? json['user'] : json;
    String? bio;
    String? position;
    int? groupId;

    if (data['teacher_profile'] != null) {
      bio = data['teacher_profile']['bio'];
      position = data['teacher_profile']['position'];
    }

    if (data['student_profile'] != null) {
      groupId = data['student_profile']['group_id'];
    }

    List<Discipline> courses = [];
    if (data.containsKey('courses') && data['courses'] is List) {
      courses = List<Map<String, dynamic>>.from(data['courses'])
          .map((c) => Discipline.fromJson(c))
          .toList();
    }

    return MyUser(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      role: data['role']['role'] ?? '',
      disciplines: courses,
      bio: bio,
      position: position,
      groupId: groupId,
    );
  }

  static var empty = MyUser(username: '', role: '', id: 0,);

  @override
  List<Object> get props => [username, role];
}
