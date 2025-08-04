import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'model/attestation.dart';

class USRRepository {
  final _baseUrl = 'http://127.0.0.1:8000/attest/api/';

  Future<List<Attestation>?> getAttestations({
    required int disciplineId,
    required int groupId,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}get_attestation/').replace(queryParameters: {
        'discipline_id': disciplineId.toString(),
        'group_id': groupId.toString(),
      });

      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data is List) {
        log('✅ Получено: $data');
        return data.map((e) => Attestation.fromJson(e)).toList();
      }

      log('❌ Ответ с ошибкой: ${response.statusCode} / $data');
      return null;
    } catch (e) {
      log('❌ Ошибка получения аттестаций: $e');
      return null;
    }
  }

  Future<bool> addUSR(int attestationId) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}add_usr/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'attestation_id': attestationId}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        log('✅ USR добавлен: $data');
        return true;
      } else {
        log('❌ Ошибка при добавлении USR: $data');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при добавлении USR: $e');
      return false;
    }
  }

  Future<bool> updateUSR({
    required int usrId,
    required int attestationId,
    required int grade,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}update_usr/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usr_id': usrId,
          'attestation_id': attestationId,
          'grade': grade,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        log('✅ USR обновлён: $data');
        return true;
      } else {
        log('❌ Ошибка обновления USR: $data');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при обновлении USR: $e');
      return false;
    }
  }

  Future<bool> deleteUSR(int attestationId) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}delete_usr/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'attestation_id': attestationId}),
      );

      if (response.statusCode == 200) {
        log('✅ USR удалён');
        return true;
      } else {
        log('❌ Ошибка удаления USR');
        return false;
      }
    } catch (e) {
      log('❌ Ошибка соединения при удалении USR: $e');
      return false;
    }
  }
}
