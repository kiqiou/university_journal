import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final String username;
  final List<String> roles;

  const MyUser({
    required this.username,
    required this.roles,
  });

  static const empty = MyUser(username: '', roles: []);

  @override
  List<Object> get props => [username, roles];
}
