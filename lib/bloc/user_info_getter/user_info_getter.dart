import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchUserData() async {
  try {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user/1/add_role/'),
      headers: {'Accept': 'application/json; charset=utf-8'},
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      print('📩 Декодированные данные: $decodedData');

      if (decodedData is Map<String, dynamic>) {
        return decodedData;
      } else {
        print('❌ Ошибка: формат ответа неверный');
        return {'error': 'Ошибка формата'};
      }
    } else {
      print('❌ Ошибка запроса: ${response.statusCode}');
      return {'error': 'Ошибка запроса'};
    }
  } catch (e) {
    print('❌ Ошибка соединения: $e');
    return {'error': 'Ошибка соединения'};
  }
}
