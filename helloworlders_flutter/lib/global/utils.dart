import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Global {
  static Future<String?> getToken() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    return await storage.read(key: "jwt_token");
  }

  static Future<void> clearToken() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.delete(key: "jwt_token");
  }
}
