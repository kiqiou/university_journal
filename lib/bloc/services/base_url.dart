import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default.url';
//http://127.0.0.1:8000
//https://university-journal-back.onrender.com
//https://university-journal-back-1.onrender.com