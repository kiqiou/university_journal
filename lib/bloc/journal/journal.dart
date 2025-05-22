import '../user/user.dart';

class Session {
  final int sessionId;
  final int courseId;
  final String? courseName;
  final String date;
  final String sessionType;
  final MyUser student;
  String? status;
  final int? grade;

  Session({required this.courseId, required this.date, required this.sessionType, required this.grade,
    required this.student, required this.status, this.courseName, required this.sessionId,});

  factory Session.fromJson(Map<String, dynamic> json) {
    final sessionJson = json['session'] ?? {};
    final courseJson = sessionJson['course'] ?? {};
    final studentJson = json['student'] ?? {};
    final roleJson = studentJson['role'] ?? {};

    return Session(
      sessionId: sessionJson['id'] ?? 0,
      courseId: courseJson['id'] ?? 0,
      courseName: courseJson['name'],
      date: sessionJson['date'] ?? '',
      sessionType: sessionJson['type'] ?? '',
      student: MyUser(
        username: studentJson['username'] ?? '',
        role: roleJson['role'] ?? '',
        id: studentJson['id'] ?? 0,
      ),
      status: json['status'],
      grade: json['grade'],
    );
  }
}
