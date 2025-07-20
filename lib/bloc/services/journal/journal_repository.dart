import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/services/journal/models/session.dart';

class JournalRepository {
  Future<List<Session>> journalData({
    required int disciplineId,
    required int groupId,
  }) async {
    final uri = Uri.parse('http://127.0.0.1:8000/session/api/get_attendance/')
        .replace(queryParameters: {
      'course_id': disciplineId.toString(),
      'group_id': groupId.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      log('$data');

      if (data is List) {
        final List<Session> sessions = [];

        for (var sessionJson in data) {
          final sessionWrapper = {
            'journal': {
              'id': sessionJson['id'],
              'date': sessionJson['date'],
              'type': sessionJson['type'],
              'topic': sessionJson['topic'],
              'subGroup': sessionJson['subGroup'],
              'course': {
                'id': sessionJson['course'],
                'name': '—',
              }
            }
          };

          for (var att in sessionJson['attendances']) {
            final item = {
              ...sessionWrapper,
              'student': att['student'],
              'status': att['status'],
              'grade': att['grade'],
              'subGroup': att['session']['subGroup'],
              'updated_at': att['updated_at'],
              'modified_by': att['modified_by'],
            };

            sessions.add(Session.fromJson(item));
          }
        }

        return sessions;
      } else {
        print('❌ Ожидался список сессий, но получен объект: $data');
        return [];
      }
    } else {
      print(
          '❌ Ошибка загрузки сессий: ${response.statusCode}, ${response.body}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateAttendance({
    required int sessionId,
    required int studentId,
    required String status,
    required String grade,
    required token,
  }) async {
    final Map<String, dynamic> body = {
      'session_id': sessionId,
      'student_id': studentId,
      'status': status,
    };

    final parsedGrade = int.tryParse(grade);
    if (parsedGrade != null) {
      body['grade'] = parsedGrade;
    }

    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/session/api/update_attendance/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      log('✅ Обновление выполнено');
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      print('Ошибка обновления: ${response.statusCode}, ${response.body}');
      return null;
    }
  }

  Future<Session?> addSession({
    required String type,
    required String date,
    required int disciplineId,
    required int groupId,
    int? subGroup,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/session/api/add_session/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          "type": type,
          "date": date,
          "course_id": disciplineId,
          "group_id": groupId,
          "subGroup": subGroup,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('📌 Ответ сервера: $data');

        return Session.fromJson({'journal': data, 'student': {}});
      } else {
        print('❌ Ошибка сервера: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
      return null;
    }
  }

  Future<bool> updateSession({
    required int id,
    String? date,
    String? type,
    String? topic,
    int? subGroup,
  }) async {
    final Map<String, dynamic> body = {};
    if (date != null) body['date'] = date;
    if (type != null) body['type'] = type;
    if (topic != null) body['topic'] = topic;
    body['subGroup'] = subGroup;

    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/session/api/update_session/$id/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('✅ Занятие обновлено');
      return true;
    } else {
      print('❌ Ошибка обновления занятия: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteSession({
    required int sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/session/api/delete_session/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({"session_id": sessionId}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null) {
        log('📌 Ответ сервера: $data');
        return true;
      } else {
        log('❌ Ошибка: неожиданный формат ответа сервера');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения: $e');
      return false;
    }
  }
}
