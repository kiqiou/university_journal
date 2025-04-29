import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:university_journal/bloc/journal/journal.dart';

class JournalRepository{
  Future<Session?> journalData() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/attendance/'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8',
      },
      body: jsonEncode({
        "session": 1,
        "student": 3,
        "status": "п",
        "grade": 8
      }),
    );
    if (response.statusCode == 201) {
      final String decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      print('✅ Данные: $data');
      return Session.fromJson(data);
    } else {
      print('❌ Ошибка: ${response.statusCode}, ${response.body}');
      return null;
    }
  }
}

