import '../user/user.dart';
import 'package:intl/intl.dart';

class Session {
  final int sessionId;
  final int courseId;
  final String? courseName;
  final String date;
  final String sessionType;
  final MyUser student;
  String? topic;
  String? status;
  String? grade;

  Session({required this.courseId, required this.date, required this.sessionType, required this.grade,
    required this.student, required this.status, this.courseName, required this.sessionId, this.topic});

  factory Session.fromJson(Map<String, dynamic> json) {
    String rawDate = json['session']['date'] ?? '';
    String formattedDate = '';
    try {
      final parsedDate = DateTime.parse(rawDate);
      formattedDate = DateFormat('dd.MM.yyyy').format(parsedDate);
    } catch (e) {
      formattedDate = rawDate;
    }

    return Session(
      sessionId: json['session']['id'] ?? 0,
      courseId: json['session']['course']['id'] ?? 0,
      courseName: json['session']['course']['name'],
      date: formattedDate,
      sessionType: json['session']['type'] ?? '',
      student: MyUser(
        username: json['student']['username'] ?? '',
        role: json['student']['role']['role'] ?? '',
        id: json['student']['id'] ?? 0,
      ),
      topic: json['session']['topic'],
      status: json['status'],
      grade: json['grade']?.toString(),
    );
  }
}
