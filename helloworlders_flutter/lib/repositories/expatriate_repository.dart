import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:helloworlders_flutter/services/expatriate_service.dart';

class ExpatriateRepository {
  final ApiExpatriateService apiExpatriateService;

  const ExpatriateRepository({required this.apiExpatriateService});

  Future<Map<String, dynamic>> getAll() async {
    try {
      Map<String, dynamic> response = await apiExpatriateService.getAll();

      if (response["statusCode"] != 200) {
        return {
          "status": "error",
          "message": response["body"]["message"] ?? "Erreur inconnue",
          "expatriates": [],
        };
      }

      final List<Expatriate> expatriates =
          Expatriate.listFromJson(response["body"]);

      return {
        "status": "success",
        "message": "Profils récupérés",
        "expatriates": expatriates,
      };
    } catch (e) {
      return {
        "status": "error",
        "message":
            "Erreur lors de la récupération des expatriés : ${e.toString()}",
        "expatriates": [],
      };
    }
  }
}
