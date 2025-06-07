import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/journal/journal.dart';

class JournalRepository {
  Future<List<Session>> journalData() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/attendance/'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8',
      },
      body: jsonEncode({"session": 1, "student": 3, "status": "п", "grade": 8}),
    );
    if (response.statusCode == 201) {
      final String decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);

      if (data is List) {
        return data.map((json) => Session.fromJson(json)).toList();
      } else {
        print('❌ Ожидался список, но получен одиночный объект: $data');
        return [];
      }
    } else {
      print('❌ Ошибка: ${response.statusCode}, ${response.body}');
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/add_session/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({"type": type, "date": date, "course_id": 1}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null && data.containsKey("course")) {
        print('📌 Ответ сервера: $data');
        return Session.fromJson(data);
      } else {
        print('❌ Ошибка: неожиданный формат ответа сервера');
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

