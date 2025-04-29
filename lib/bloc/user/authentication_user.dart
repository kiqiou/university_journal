import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/user/user.dart';

class AuthRepository {
  Future<MyUser?> signUp(String username, String password, int roleId) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/api/register/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'role_id': roleId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['username'] != null && data['role'] != null) {
          print('✅ Username: ${data['username']}');
          return MyUser.fromJson(data);
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
        Uri.parse('http://127.0.0.1:8000/auth/api/login/'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        print('✅ Успешный вход!');
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('📌 Ответ сервера: $data');
        if (data is Map<String, dynamic> && data['user'] != null) {
          return MyUser.fromJson(data);
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
  Future<void> logout() async {
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/auth/logout/'));
    if (response.statusCode != 200) {
      throw Exception('Ошибка при выходе из аккаунта');
    }
  }
}


