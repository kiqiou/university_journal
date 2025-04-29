import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final String username;
  final String role;

  const MyUser({
    required this.username,
    required this.role,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson == null) {
      print('❌ Ошибка: JSON не содержит user');
      return MyUser(username: '', role: '');
    }
    return MyUser(
      username: userJson['username'] ?? '',
      role: userJson['role']?['role'] ?? '',
    );
  }

  static const empty = MyUser(username: '', role: '',);

  @override
  List<Object> get props => [username, role];
}
