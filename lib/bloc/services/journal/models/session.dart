import 'dart:developer';

import 'package:intl/intl.dart';

import '../../user/models/user.dart';

class Session {
  final int id;
  final int disciplineId;
  final String? disciplineName;
  final String date;
  final String type;
  final MyUser student;
  String? topic;

  String? status;
  String? grade;
  String? modifiedByUsername;
  DateTime? updatedAt;

  Session({
    required this.disciplineId,
    required this.date,
    required this.type,
    required this.grade,
    required this.student,
    required this.status,
    this.disciplineName,
    required this.id,
    this.topic,
    this.modifiedByUsername,
    this.updatedAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    String rawDate = json['journal']['date'] ?? '';
    String formattedDate = '';
    try {
      final parsedDate = DateTime.parse(rawDate);
      formattedDate = DateFormat('dd.MM.yyyy').format(parsedDate);
    } catch (e) {
      formattedDate = rawDate;
    }

    return Session(
      id: json['journal']['id'] ?? 0,
      disciplineId: json['journal']['course']['id'] ?? 0,
      disciplineName: json['journal']['course']['name'],
      date: formattedDate,
      type: json['journal']['type'] ?? '',
      student: MyUser(
        username: json['student']['username'] ?? '',
        role: json['student']['role']['role'] ?? '',
        id: json['student']['id'] ?? 0,
      ),
      topic: json['journal']['topic'],
      status: json['status'],
      grade: json['grade']?.toString(),
      modifiedByUsername: json['modified_by']?['username'],
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Session copyWith({
    int? id,
    int? disciplineId,
    String? disciplineName,
    String? date,
    String? type,
    MyUser? student,
    String? topic,
    String? status,
    String? grade,
    String? modifiedByUsername,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      disciplineId: disciplineId ?? this.disciplineId,
      disciplineName: disciplineName ?? this.disciplineName,
      date: date ?? this.date,
      type: type ?? this.type,
      student: student ?? this.student,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      modifiedByUsername: modifiedByUsername ?? this.modifiedByUsername,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  List<Object?> get props => [id, date, type];
}
