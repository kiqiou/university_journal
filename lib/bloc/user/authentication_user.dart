import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/user/user.dart';

class AuthRepository{
  Future<void> signUp(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/register/'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Успешная регистрация!');
      } else {
        print('❌ Ошибка регистрации: ${response.body}');
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
    }
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
        final data = jsonDecode(response.body);
        print('👤 Данные пользователя: $data');
        return MyUser(
          username: data['user']['username'],
          roles: (data['user']['role'] as List)
              .map((role) => role['role'] as String)
              .toList(),
        );
      } else {
        print('❌ Ошибка входа: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
      return null;
    }
  }
}

