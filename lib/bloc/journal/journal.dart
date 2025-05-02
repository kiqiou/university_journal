import '../user/user.dart';

class Session {
  final int courseId;
  final String? courseName;
  final String date;
  final String sessionType;
  final MyUser student;
  String status;
  final int grade;

  Session({required this.courseId, required this.date, required this.sessionType, required this.grade, required this.student, required this.status, this.courseName});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      courseId: json['session']['course']['id'],
      courseName: json['session']['course']['name'],
      date: json['session']['date'],
      sessionType: json['session']['type'],
      student: MyUser(username: json['student']['username'], role: json['student']['role']['role'], id: json['student']['id']),
      status: json['status'],
      grade: json['grade'],
    );
  }
}
