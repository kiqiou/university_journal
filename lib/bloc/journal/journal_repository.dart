import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/journal/journal.dart';

import '../user/user.dart';

class JournalRepository {
  Future<List<Session>> journalData() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/attendance/'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8',
      },
      body: jsonEncode({}),
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

  Future<List<MyUser>?> getTeacherList () async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/get_teacher_list/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null && data is List) {
        log('📌 Ответ сервера: $data');
        return data.map((json) => MyUser.fromJson(json)).toList();
      } else {
        log('❌ Ошибка: неожиданный формат ответа сервера');
        return null;
      }
    } catch (e) {
      log('❌ Ошибка соединения: $e');
      return null;
    }
  }

  Future<bool> deleteUser({
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/delete_user/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({"user_id": userId}),
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
