import 'package:helloworlders_flutter/services/auth_service.dart';

class AuthRepository {
  final ApiAuthService apiAuthService;

  const AuthRepository({
    required this.apiAuthService,
  });

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      Map<String, dynamic> response =
          await apiAuthService.login(email, password);

      if (response["statusCode"] != 200) {
        return {
          "status": "error",
          "message": response["body"]["message"] ?? "Erreur inconnue",
        };
      }

      return {
        "status": "success",
        "token": response["body"],
        "message": "Connexion réussie",
      };
    } catch (e) {
      return {
        "status": "error",
        "message": "Erreur lors de la connexion : ${e.toString()}",
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String email,
  ) async {
    try {
      Map<String, dynamic> response =
          await apiAuthService.register(username, password, email);

      if (response["statusCode"] != 200) {
        return {
          "status": "error",
          "message": response["body"]["message"] ?? "Erreur inconnue",
        };
      }

      return {
        "status": "success",
        "message": "Compte enregistré",
      };
    } catch (e) {
      return {
        "status": "error",
        "message": "Erreur lors de l'enregistrement : ${e.toString()}",
      };
    }
  }
}
