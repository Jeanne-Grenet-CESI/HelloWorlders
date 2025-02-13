import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiExpatriateService {
  Future<Map<String, dynamic>> getAll() async {
    String url = "${dotenv.env['API_URL']}/ApiExpatriate/getAll";
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': "application/json",
      },
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body)
    };
  }
}
