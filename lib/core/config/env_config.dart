import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://api.exconvert.com';
  
  static String get accessKey => dotenv.env['ACCESS_KEY'] ?? '270ca084-96a82de7-ae4aff0f-60b941d9';
  
  static bool get useMockData => dotenv.env['USE_MOCK'] == 'true';
  
  // Load environment
  static Future<void> load({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }
}