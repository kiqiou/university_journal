import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/user/user.dart';

class UserRepository {
  Future<MyUser?> signUp({
    required String username,
    required String password,
    required int roleId,
    int? groupId,
    String? position,
    String? bio,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
        'role_id': roleId,
      };

      if (roleId == 1) {
        requestBody['position'] = position;
        requestBody['bio'] = bio;
      } else if (roleId == 2) {
        requestBody['group_id'] = groupId;
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/api/register/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('📦 Ответ сервера: $data');
        if (data['username'] != null && data['role'] != null) {
          print('✅ Username: ${data['username']}');
          return MyUser.fromJson(data);
        } else {
          print('❌ Неверный формат данных: $data');
          return null;
        }
      } else {
        print('❌ Ошибка регистрации: ${response.body}');
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
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

  Future<List<MyUser>?> getTeacherList() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/get_teacher_list/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null && data is List) {
        log('📌 Ответ сервера: $data');
        return data.map((json) => MyUser.fromJson(json)).toList();
      } else {
        log('❌ Ошибка: неожиданный формат ответа сервера');
        return null;
      }
    } catch (e) {
      log('❌ Ошибка соединения: $e');
      return null;
    }
  }

  Future<bool> updateUser({
    required int userId,
    String? username,
    String? position,
    String? bio,
    int? groupId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/update_user/$userId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'position': position,
          'bio': bio,
          'group_id': groupId,
        }),
      );
      log('🔍 Отправка обновления для userId: $userId');
      if (response.statusCode == 200) {
        return true;
      } else {
        log('❌ Ошибка обновления преподавателя: ${response.body}');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения: $e');
      return false;
    }
  }

  Future<bool> deleteUser({
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/delete_user/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({"user_id": userId}),
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


