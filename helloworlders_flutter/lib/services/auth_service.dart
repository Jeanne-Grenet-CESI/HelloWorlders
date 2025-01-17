import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    String url = "http://192.168.88.168:80/User/loginjwt";
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': "application/json",
      },
      body: jsonEncode({
        "Email": email,
        "Password": password,
      }),
    );

    return {"statusCode": response.statusCode, "body": response.body};
  }
}
