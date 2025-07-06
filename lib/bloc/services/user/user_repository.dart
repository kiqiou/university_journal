import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/services/user/models/user.dart';

import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class UserRepository {
  Future<MyUser?> signUp({
    required String username,
    required String password,
    required int roleId,
    int? groupId,
    String? position,
    String? bio,
    bool? isHeadman,
    Uint8List? photoBytes,
    String? photoName,
  }) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/auth/api/register/');
      final request = http.MultipartRequest('POST', uri);
      request.fields['username'] = username;
      request.fields['password'] = password;
      request.fields['role_id'] = roleId.toString();

      if (roleId == 1) {
        if (position != null) request.fields['position'] = position;
        if (bio != null) request.fields['bio'] = bio;
        if (photoBytes != null && photoName != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo',
              photoBytes,
              filename: photoName,
              contentType: MediaType.parse(
                  lookupMimeType(photoName) ?? 'application/octet-stream'),
            ),
          );
        }
      } else if (roleId == 5 && groupId != null) {
        request.fields['group_id'] = groupId.toString();
        log('➡️ Перед обновлением isHeadman = $isHeadman');
        request.fields['isHeadman'] = isHeadman ?? false ? '1' : '0';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
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
        return null;
      }
    } catch (e) {
      print('❌ Ошибка соединения: $e');
      return null;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/api/token/'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        if (accessToken != null && refreshToken != null) {
          await saveTokens(accessToken, refreshToken);
          print('Токены сохранены');
          return true;
        }
      } else {
        print('Ошибка входа: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Ошибка соединения: $e');
      return false;
    }
    return false;
  }

  Future<MyUser?> fetchUser() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/auth/api/user/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return MyUser.fromJson(data);
    } else if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) return await fetchUser();
    }
    return null;
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/auth/logout/'),
      headers: {
        'Authorization': 'Bearer ${await getAccessToken()}',
      },
    );
    if (response.statusCode == 200) {
      await clearTokens();
      print('Выход выполнен');
    } else {
      throw Exception('Ошибка при выходе');
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/auth/api/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];
      if (newAccessToken != null) {
        await saveTokens(newAccessToken, refreshToken);
        return true;
      }
    }

    await clearTokens();
    return false;
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

  Future<List<MyUser>?> getStudentList() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/get_student_list/'),
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

  Future<List<MyUser>?> getStudentsByGroupList(int groupId) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/get_students_by_group/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'group_id': groupId,
        }),
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
    bool? isHeadman,
    int? groupId,
    Uint8List? photoBytes,
    String? photoName,
  }) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/update_user/$userId/');
      final request = http.MultipartRequest('PUT', uri);

      request.fields['username'] = username ?? '';
      request.fields['position'] = position ?? '';
      request.fields['bio'] = bio ?? '';
      if (groupId != null) {
        request.fields['group_id'] = groupId.toString();
      }
      if (isHeadman != null) {
        log('➡️ Перед обновлением isHeadman = $isHeadman');
        request.fields['isHeadman'] = isHeadman ? '1' : '0';
      }

      if (photoBytes != null && photoName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoBytes,
            filename: photoName,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('🔍 Ответ сервера: ${response.statusCode} ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      log('❌ Ошибка обновления: $e');
      return false;
    }
  }

  Future<bool> updateTeacherDisciplines({
    required int teacherId,
    required List<int> disciplineIds,
  }) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/update_teacher_disciplines/');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teacher_id': teacherId,
          'discipline_ids': disciplineIds,
        }),
      );

      log('📤 Отправлено обновление: $teacherId — $disciplineIds');
      log('📥 Ответ: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      log('❌ Ошибка при обновлении дисциплин преподавателя: $e');
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
