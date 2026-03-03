import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'https://university-journal-back.onrender.com'
);
//http://127.0.0.1:8000
//https://university-journal-back.onrender.com

