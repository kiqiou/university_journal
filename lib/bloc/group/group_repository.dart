import 'dart:convert';
import 'dart:developer';

import 'group.dart';
import 'package:http/http.dart' as http;

class GroupRepository {
  Future<List<Group>?> getGroupsList() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/get_groups_list'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8',
      },);

    print('Полученные данные: ${response.body} ');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((groupJson) => Group.fromJson(groupJson)).toList();
    } else {
      throw Exception('Не удалось загрузить список групп');
    }
  }

  Future<bool> addGroup({
    int? courseId,
    required String name,
    required List<int> teacherIds,
    required List<int> groupIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/add_or_update_course/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'id': courseId, // ← передаём id, если это редактирование
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
}