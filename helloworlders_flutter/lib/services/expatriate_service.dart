import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:helloworlders_flutter/global/utils.dart';
import 'package:http/http.dart' as http;

class ApiExpatriateService {
  Future<List<dynamic>> getAll({
    required int limit,
    required int offset,
    String? country,
  }) async {
    String url =
        "${dotenv.env['API_URL']}/ApiExpatriate/getAll?limit=$limit&offset=$offset";

    if (country != null && country.isNotEmpty) {
      url += "&country=$country";
    }

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

  Future<Map<String, dynamic>> createExpatriate(
      Map<String, dynamic> expatriateData) async {
    try {
      String url = "${dotenv.env['API_URL']}/ApiExpatriate/add";
      final token = await Global.getToken();

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(expatriateData),
      );

      if (response.statusCode == 200) {
        return {
          "statusCode": response.statusCode,
          "body": jsonDecode(response.body)
        };
      } else {
        return {
          "statusCode": response.statusCode,
          "body": jsonDecode(response.body)
        };
      }
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"message": "Erreur lors de la création: ${e.toString()}"}
      };
    }
  }

  Future<String?> imageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    } catch (e) {
      return null;
    }
  }
}
