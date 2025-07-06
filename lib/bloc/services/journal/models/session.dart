import 'dart:developer';

import 'package:intl/intl.dart';

import '../../user/models/user.dart';

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

  // Приватные поля для хранения исходных значений
  String? _originalStatus;
  String? _originalGrade;

  // Новые поля — кто и когда изменил
  String? modifiedByUsername;
  DateTime? updatedAt;

  Session({
    required this.disciplineId,
    required this.date,
    required this.sessionType,
    required this.grade,
    required this.student,
    required this.status,
    this.disciplineName,
    required this.id,
    this.topic,
    this.modifiedByUsername,
    this.updatedAt,
  }) {
    _originalStatus = status;
    _originalGrade = grade;
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    String rawDate = json['session']['date'] ?? '';
    String formattedDate = '';
    try {
      final parsedDate = DateTime.parse(rawDate);
      formattedDate = DateFormat('dd.MM.yyyy').format(parsedDate);
    } catch (e) {
      formattedDate = rawDate;
    }

    log('${json['modified_by']?['username']}, ${json['updated_at']}');

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
      modifiedByUsername: json['modified_by']?['username'],
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}
