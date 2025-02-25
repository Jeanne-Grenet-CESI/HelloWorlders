import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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

  static Future<int> isAuthenticated() async {
    String url = "${dotenv.env['API_URL']}/User/apiIsConnected";
    final token = await getToken();
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode;
  }
}
