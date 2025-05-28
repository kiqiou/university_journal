import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final int id;
  final String username;
  final String role;
  String? bio;
  String? position;
  int? groupId;

  MyUser({
    required this.id,
    required this.username,
    required this.role,
    this.bio,
    this.position,
    this.groupId,
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

    return MyUser(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      role: data['role']['role'] ?? '',
      bio: bio,
      position: position,
      groupId: groupId,
    );
  }

  static var empty = MyUser(username: '', role: '', id: 0,);

  @override
  List<Object> get props => [username, role];
}
