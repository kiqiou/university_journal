import 'package:equatable/equatable.dart';
import '../discipline/discipline.dart';

class MyUser extends Equatable {
  final int id;
  final String username;
  final String role;
  final String? bio;
  final String? position;
  final int? groupId;
  final String? groupName;
  final String? facultyName;
  final String? disciplineName;
  final String? photoUrl;
  final List<Discipline> disciplines;

  const MyUser({
    required this.id,
    required this.username,
    required this.role,
    this.bio,
    this.position,
    this.groupId,
    this.groupName,
    this.facultyName,
    this.disciplineName,
    this.photoUrl,
    this.disciplines = const [],
  });

  factory MyUser.fromGroupJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'],
      username: json['username'],
      role: 'Студент',
    );
  }

  factory MyUser.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('user') ? json['user'] : json;
    String? bio;
    String? position;
    int? groupId;
    String? groupName;
    String? photoUrl;
    String? facultyName;
    String? courseName;

    if (data['teacher_profile'] != null) {
      bio = data['teacher_profile']['bio'];
      position = data['teacher_profile']['position'];
      photoUrl = data['teacher_profile']?['photo'] != null
          ? 'http://127.0.0.1:8000${data['teacher_profile']['photo']}'
          : null;
    }

    if (data['group'] != null) {
      groupId = data['group']['id'];
      groupName = data['group']['name'];
      facultyName = data['group']['faculty']['name'];
      courseName = data['group']['course']['name'];
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
      groupName: groupName,
      facultyName: facultyName,
      disciplineName: courseName,
      photoUrl: photoUrl,
    );
  }

  static var empty = MyUser(username: '', role: '', id: 0,);

  @override
  List<Object> get props => [username, role];
}
