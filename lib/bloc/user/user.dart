import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final int? id;
  final String username;
  final String role;

  const MyUser({
    this.id,
    required this.username,
    required this.role,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    if (json['user'] == null) {
      print('❌ Ошибка: JSON не содержит user');
      return MyUser(username: '', role: '');
    }
    return MyUser(
      username: json['user']['username'] ?? '',
      role:json['user']['role']?['role'] ?? '',
    );
  }

  static const empty = MyUser(username: '', role: '',);

  @override
  List<Object> get props => [username, role];
}
