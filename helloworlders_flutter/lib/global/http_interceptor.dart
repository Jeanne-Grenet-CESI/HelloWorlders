import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/global/navigator_observer.dart';
import 'package:helloworlders_flutter/global/utils.dart';
import 'package:http/http.dart' as http;

class HttpInterceptor extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await Global.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      await Global.clearToken();

      if (AppNavigatorObserver.currentContext != null) {
        Future.microtask(() {
          ScaffoldMessenger.of(AppNavigatorObserver.currentContext!)
              .showSnackBar(
            const SnackBar(
              content:
                  const Text("Session expirée, veuillez vous reconnecter."),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            AppNavigatorObserver.currentContext!,
            '/login',
            (route) => false,
          );
        });
      }
    }

    return response;
  }
}
