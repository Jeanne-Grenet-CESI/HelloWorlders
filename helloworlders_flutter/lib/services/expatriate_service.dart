import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiExpatriateService {
  Future<List<dynamic>> getAll({
    required int limit,
    required int offset,
  }) async {
    String url =
        "${dotenv.env['API_URL']}/ApiExpatriate/getAll?limit=$limit&offset=$offset";

    try {
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load expatriates');
      }
    } catch (e) {
      rethrow;
    }
  }
}
