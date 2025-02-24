import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helloworlders_flutter/global/utils.dart';
import 'package:http/http.dart' as http;

class ApiUserService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      String url = "${dotenv.env['API_URL']}/User/apiAccount";

      final http.Response response = await Global.httpClient.get(
        Uri.parse(url),
        headers: {
          'Content-Type': "application/json",
        },
      );
      print(response.body);
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
        "body": {"message": "Erreur lors de la récupération: ${e.toString()}"}
      };
    }
  }
}
