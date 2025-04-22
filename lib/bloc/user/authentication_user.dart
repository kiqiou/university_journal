import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/user/user.dart';

class AuthRepository {
  Future<MyUser?> signUp(String username, String password, List<int> roleIds) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/register/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: utf8.encode(jsonEncode({
          'username': username,
          'password': password,
          'role_ids': roleIds,
        })),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['username'] != null && data['role'] != null) {
          print('✅ Username: ${data['username']}');
          return MyUser(
            username: data['username'] ?? 'Гость',
            roles: (data['role'] as List?)
                    ?.map((role) => role['role']?.toString() ?? '')
                    .where((r) => r.isNotEmpty)
                    .toList() ??
                [],
          );
        } else {
          print('❌ Неверный формат данных: $data');
          return null;
        }
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
      return null;
    }
    return null;
  }

  Future<MyUser?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/login/'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        print('✅ Успешный вход!');
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['user'] != null && data['user']['role'] != null) {
          final rawRoles = data['user']['role'] as List;
          final parsedRoles = rawRoles
              .map((role) => role['role'])
              .whereType<String>() // <-- Это ВАЖНО!
              .toList();
          print('➡️ Сырые данные: ${response.body}');
          print('➡️ Декодированные данные: $data');
          return MyUser(
            username: data['user']['username']?.toString() ?? 'Гость',
            roles: parsedRoles,
          );
        }
      } else {
        print('❌ Ошибка: Нет информации о пользователе или ролях');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
      return null;
    }
    return null;
  }
}
