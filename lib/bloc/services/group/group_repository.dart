import 'dart:convert';
import 'dart:developer';

import '../base_url.dart';
import 'models/group.dart';
import 'package:http/http.dart' as http;

class GroupRepository {
  Future<List<Group>?> getGroupsList(
      List<String>? faculties,
      List<int>? courses,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/group/api/get_groups_list/'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8',
      },
      body: jsonEncode({
        'faculties': faculties,
        'courses': courses,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((groupJson) => Group.fromJson(groupJson)).toList();
    } else {
      throw Exception('Не удалось загрузить список групп');
    }
  }

  Future<List<GroupSimple>?> getGroupsSimpleList({
    List<String>? faculties,
    List<int>? courses,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/group/api/get_groups_simple_list/'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'faculties': faculties, 'courses': courses}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((groupJson) => GroupSimple.fromJson(groupJson)).toList();
    } else {
      throw Exception('Не удалось загрузить список простых групп');
    }
  }

  Future<bool> addGroup({
    required String name,
    required List<int> studentIds,
    required int courseId,
    required int facultyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/group/api/add_group/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'name': name,
          'students': studentIds,
          'faculty': facultyId,
          'course': courseId,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ Группа успешно сохранена: $data');
        return true;
      } else {
        log('❌ Ошибка сохранения группы: ${response.statusCode}, $data');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при сохранении группы: $e');
      return false;
    }
  }

  Future<bool> updateGroup({
    required int groupId,
    String? name,
    List<int>? studentIds,
    int? courseId,
    int? facultyId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/group/api/update_group/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'group_id': groupId,
          'name': name,
          'students': studentIds,
          'faculty': facultyId,
          'course': courseId,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ Группа успешно сохранена: $data');
        return true;
      } else {
        log('❌ Ошибка сохранения группы: ${response.statusCode}, $data');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при сохранении группы: $e');
      return false;
    }
  }

  Future<bool> deleteGroup({
    required int groupId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/group/api/delete_group/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({"group_id": groupId}),
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
