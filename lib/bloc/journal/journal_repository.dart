import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/journal/journal.dart';

class JournalRepository {
  Future<List<Session>> journalData({
    required int courseId,
    required int groupId,
  }) async {
    final uri = Uri.parse('http://127.0.0.1:8000/api/get_attendance/')
        .replace(queryParameters: {
      'course_id': courseId.toString(),
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
            'session': {
              'id': sessionJson['id'],
              'date': sessionJson['date'],
              'type': sessionJson['type'],
              'topic': sessionJson['topic'],
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
      print('❌ Ошибка загрузки сессий: ${response.statusCode}, ${response.body}');
      return [];
    }
  }

  Future<bool> updateAttendance({required int sessionId, required int studentId, required String status, required String grade}) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/update_attendance/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'student_id': studentId,
        'grade': int.parse(grade),
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      log('✅ Обновление оценивания выполнено успешно');
      return true;
    } else {
      print('Ошибка обновления: ${response.statusCode}, ${response.body}');
      return false;
    }
  }

  Future<bool> updateSession({
    required int sessionId,
    String? date,
    String? type,
    String? topic,
  }) async {
    final Map<String, dynamic> body = {};
    if (date != null) body['date'] = date;
    if (type != null) body['type'] = type;
    if (topic != null) body['topic'] = topic;

    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/api/update_session/$sessionId/'),
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

  Future<Session?> addSession({
    required String type,
    required String date,
    required int courseId,
    required int groupId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/add_session/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          "type": type,
          "date": date,
          "course_id": courseId,
          "group_id": groupId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('📌 Ответ сервера: $data');

        return Session.fromJson({'session': data, 'student': {}});

      } else {
        print('❌ Ошибка сервера: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
      return null;
    }
  }

  Future<bool> deleteSession({
    required int sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/delete_session/'),
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
    }
    catch(e){
      log('❌ Ошибка соединения: $e');
      return false;
    }
  }
}

