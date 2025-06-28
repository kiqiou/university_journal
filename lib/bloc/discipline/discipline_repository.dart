import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'discipline.dart';

class DisciplineRepository{
  Future<List<Discipline>?> getDisciplinesList() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/get_courses_list/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({}),
      );

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

  Future<bool> addDiscipline({
    required String name,
    required List<int> teacherIds,
    required List<int> groupIds,
    required List<Map<String, dynamic>> planItems,
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
          'plan_items': planItems,
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

  Future<bool> updateDiscipline({
    required int courseId,
    String? name,
    List<int>? teacherIds,
    List<int>? groupIds,
    required bool appendTeachers,
    List<Map<String, dynamic>>? planItems, // nullable
  }) async {
    try {
      final Map<String, dynamic> body = {
        'course_id': courseId,
        'append_teachers': appendTeachers,
      };

      if (name != null) body['name'] = name;
      if (teacherIds != null) body['teachers'] = teacherIds;
      if (groupIds != null) body['groups'] = groupIds;
      if (planItems != null) body['plan_items'] = planItems;

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/update_course/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ Курс успешно обновлён: $data');
        return true;
      } else {
        log('❌ Ошибка обновления курса: ${response.statusCode}, $data');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при обновлении курса: $e');
      return false;
    }
  }


  Future<bool> deleteDiscipline({
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