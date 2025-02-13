import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class Global {
  static Future<String?> getToken() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    return await storage.read(key: "jwt_token");
  }

  static Future<void> clearToken() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.delete(key: "jwt_token");
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String getImagePath(String imageRepository, String imageFileName) {
    return '${dotenv.env['API_URL']}/uploads/images/$imageRepository/$imageFileName';
  }
}
