import 'package:equatable/equatable.dart';
import '../../discipline/models/discipline.dart';

class MyUser extends Equatable {
  final int id;
  final String username;
  final String role;
  final String? bio;
  final String? position;
  final bool? isHeadman;
  final int? subGroup;
  final int? groupId;
  final String? groupName;
  final String? faculty;
  final String? course;
  final String? photoUrl;
  final List<Discipline> disciplines;

  const MyUser({
    required this.id,
    required this.username,
    required this.role,
    this.bio,
    this.position,
    this.isHeadman,
    this.groupId,
    this.subGroup,
    this.groupName,
    this.faculty,
    this.course,
    this.photoUrl,
    this.disciplines = const [],
  });

  factory MyUser.fromGroupJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'],
      username: json['username'],
      subGroup: json['subGroup'],
      role: 'Студент',
      isHeadman: json['isHeadman'],
    );
  }

  factory MyUser.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('user') ? json['user'] : json;
    String? bio;
    String? position;
    bool? isHeadman;
    int? groupId;
    int? subGroup;
    String? groupName;
    String? photoUrl;
    String? faculty;
    String? course;

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
      faculty = data['group']['faculty']['name'];
      course = data['group']['course']['name'];
    }

    if(data['subGroup'] != null){
      subGroup = data['subGroup'];
      print('Student subGroup: ${data['subGroup']}');
    }

    if(data['isHeadman'] != null){
      isHeadman = data['isHeadman'];
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
      isHeadman: isHeadman,
      groupId: groupId,
      subGroup: subGroup,
      groupName: groupName,
      faculty: faculty,
      course: course,
      photoUrl: photoUrl,
    );
  }

  static var empty = MyUser(username: '', role: '', id: 0,);

  @override
  List<Object> get props => [username, role];
}
