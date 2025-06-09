import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'discipline.dart';

class DisciplineRepository{
  Future<List<Discipline>?> getCoursesList() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/get_courses_list/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({}),
      );
      log('Raw response: ${response.body}');

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null && data is List) {
        log('📌 Ответ сервера: $data');
        return data.map((json) => Discipline.fromJson(json)).toList();
      } else {
        log('❌ Ошибка: неожиданный формат ответа сервера');
        return null;
      }
    } catch (e) {
      log('❌ Ошибка соединения: $e');
      return null;
    }
  }

  Future<bool> addCourse({
    required String name,
    required List<int> teacherIds,
    required List<int> groupIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/add_course/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'name': name,
          'teachers': teacherIds,
          'groups': groupIds,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ Курс успешно сохранён: $data');
        return true;
      } else {
        log('❌ Ошибка сохранения курса: ${response.statusCode}, $data');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при сохранении курса: $e');
      return false;
    }
  }

  Future<bool> updateCourse({
    int? courseId,
    String? name,
    List<int>? teacherIds,
    List<int>? groupIds,
    required bool appendTeachers,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/update_course/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'course_id': courseId,
          'name': name,
          'teachers': teacherIds,
          'groups': groupIds,
          'append_teachers': appendTeachers,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ Курс успешно сохранён: $data');
        return true;
      } else {
        log('❌ Ошибка сохранения курса: ${response.statusCode}, $data');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при сохранении курса: $e');
      return false;
    }
  }

  Future<bool> deleteCourse({
    required int courseId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/delete_course/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({"course_id": courseId}),
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