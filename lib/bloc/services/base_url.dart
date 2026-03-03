import 'package:flutter_dotenv/flutter_dotenv.dart';

const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://university-journal-back.onrender.com'
);
//http://127.0.0.1:8000
//https://university-journal-back.onrender.com

