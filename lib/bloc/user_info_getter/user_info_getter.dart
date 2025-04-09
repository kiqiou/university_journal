import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchUserData() async {
  try {
    var response = await http.get(Uri.parse('http://localhost:8080'));

    if (response.statusCode == 200) {
      print('✅ Данные пользователя: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('❌ Ошибка запроса: ${response.statusCode}');
      return {'error': 'Ошибка запроса'};
    }
  } catch (e) {
    print('❌ Ошибка: $e');
    return {'error': 'Ошибка соединения'};
  }
}
