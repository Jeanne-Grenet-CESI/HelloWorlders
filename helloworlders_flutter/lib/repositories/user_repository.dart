import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:helloworlders_flutter/models/user.dart';
import 'package:helloworlders_flutter/services/user_service.dart';

class UserRepository {
  final ApiUserService apiUserService;

  const UserRepository({
    required this.apiUserService,
  });

  Future<Map<String, dynamic>> getUserAccount() async {
    try {
      Map<String, dynamic> response = await apiUserService.getUserInfo();

      if (response["statusCode"] != 200) {
        return {
          "status": "error",
          "message": response["body"]["message"] ?? "Erreur inconnue",
        };
      }

      User user = User.fromJson(response["body"]["user"]);

      List<Expatriate> expatriates = [];
      if (response["body"]["expatriates"] != null) {
        var expatriatesData = response["body"]["expatriates"];

        if (expatriatesData is List) {
          for (var item in expatriatesData) {
            if (item is Map<String, dynamic> && item.isNotEmpty) {
              expatriates.add(Expatriate.fromJson(item));
            }
          }
        }
      }

      return {
        "status": "success",
        "user": user,
        "expatriates": expatriates,
      };
    } catch (e) {
      return {
        "status": "error",
        "message": "Erreur lors de la récupération du compte: ${e.toString()}",
      };
    }
  }
}
