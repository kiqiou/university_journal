import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final int id;
  final String username;
  final String role;

  const MyUser({
    required this.id,
    required this.username,
    required this.role,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('user') ? json['user'] : json;
    return MyUser(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      role: data['role']['role'] ?? '',
    );
  }

  static const empty = MyUser(username: '', role: '', id: 0,);

  @override
  List<Object> get props => [username, role];
}
