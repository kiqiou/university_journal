import '../user/user.dart';
import 'package:intl/intl.dart';

class Session {
  final int id;
  final int disciplineId;
  final String? disciplineName;
  final String date;
  final String sessionType;
  final MyUser student;
  String? topic;
  String? status;
  String? grade;

  Session({required this.disciplineId, required this.date, required this.sessionType, required this.grade,
    required this.student, required this.status, this.disciplineName, required this.id, this.topic});

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
      id: json['session']['id'] ?? 0,
      disciplineId: json['session']['course']['id'] ?? 0,
      disciplineName: json['session']['course']['name'],
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
