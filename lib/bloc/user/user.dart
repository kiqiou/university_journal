import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final String username;
  final String role;

  const MyUser({
    required this.username,
    required this.role,
  });

  static const empty = MyUser(username: '', role: '');

  @override
  List<Object> get props => [username, role];
}
