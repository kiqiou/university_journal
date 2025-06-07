import 'dart:convert';

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
}