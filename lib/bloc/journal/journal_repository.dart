import 'dart:convert';

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

      if (response.statusCode == 201) {
        print('✅ Занятие успешно добавлено!');
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('📌 Ответ сервера: $data');
        return Session.fromJson(data);
      } else {
        print('❌ Ошибка добавления: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
      return null;
    }
  }
}
