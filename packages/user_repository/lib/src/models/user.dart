import 'package:user_repository/src/entities/user_entity.dart';

class MyUser {
  String userId;
  String email;
  String name;
  String role;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    role: ''
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      role: role,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
        userId: entity.userId,
        email: entity.email,
        name: entity.name,
      role: entity.role,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $role';
  }
}