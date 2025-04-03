class MyUserEntity {
  String userId;
  String email;
  String name;
  String role;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role' : role,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'],
      email: doc['email'],
      name: doc['name'],
      role: doc['role'],
    );
  }
}