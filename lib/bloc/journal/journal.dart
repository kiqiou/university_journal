import '../user/user.dart';

class Session {
  final int courseId;
  final String date;
  final String sessionType;
  final MyUser student;
  final String status;
  final int grade;

  Session({required this.courseId, required this.date, required this.sessionType, required this.grade, required this.student, required this.status,});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      courseId: json['session']['course'],
      date: json['session']['date'],
      sessionType: json['session']['type'],
      student: MyUser.fromJson(json['student']),
      status: json['status'],
      grade: json['grade'],
    );
  }
}
