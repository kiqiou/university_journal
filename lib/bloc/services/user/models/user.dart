import 'package:equatable/equatable.dart';
import '../../base_url.dart';
import '../../discipline/models/discipline.dart';
import '../../group/models/group.dart';

class MyUser extends Equatable {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String role;
  final String? bio;
  final String? position;
  final bool? isHeadman;
  final int? subGroup;
  final SimpleGroup? group;
  final String? photoUrl;
  final List<Discipline> disciplines;

  const MyUser({
    required this.id,
    required this.username,
    required this.role,
    this.firstName,
    this.lastName,
    this.middleName,
    this.bio,
    this.position,
    this.isHeadman,
    this.group,
    this.subGroup,
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
    int? subGroup;
    String? photoUrl;
    SimpleGroup? group;

    if (data['teacher_profile'] != null) {
      final teacher = data['teacher_profile'];

      bio = teacher['bio'];
      position = teacher['position'];

      if (teacher['photo'] != null) {
        photoUrl = baseUrl + teacher['photo'];
      }
    }

    if (data['student_profile'] != null) {
      final student = data['student_profile'];

      isHeadman = student['isHeadman'];
      subGroup = student['subGroup'];

      if (student['group'] != null) {
        group = SimpleGroup.fromJson(student['group']);
      }
    }

    List<Discipline> courses = [];
    if (data.containsKey('courses') && data['courses'] is List) {
      courses = List<Map<String, dynamic>>.from(data['courses'])
          .map((c) => Discipline.fromJson(c))
          .toList();
    }

    return MyUser(
      id: data['id'],
      username: data['username'] ?? '',
      role: data['role']?['role'] ?? '',
      firstName: data['first_name'],
      lastName: data['last_name'],
      middleName: data['middle_name'],
      disciplines: courses,
      bio: bio,
      position: position,
      isHeadman: isHeadman,
      group: group,
      subGroup: subGroup,
      photoUrl: photoUrl,
    );
  }

  static var empty = MyUser(username: '', role: '', id: 0,);

  @override
  List<Object> get props => [username, role];
}
