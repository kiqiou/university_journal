class MyUser {
  final String username;
  final List<String> roles;

  MyUser({
    required this.username,
    required this.roles,
  });

  static final empty = MyUser(
    username: '',
    roles: [],
  );
}
