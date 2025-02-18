import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:helloworlders_flutter/services/expatriate_service.dart';

class ExpatriateRepository {
  final ApiExpatriateService apiExpatriateService;
  final int _limit = 30;

  ExpatriateRepository({required this.apiExpatriateService});

  Future<Map<String, dynamic>> getAll({
    bool isLoadMore = false,
    required int page,
  }) async {
    try {
      final offset = page * _limit;

      List<dynamic> response = await apiExpatriateService.getAll(
        limit: _limit,
        offset: offset,
      );

      if (response.isEmpty) {
        return {
          "status": "success",
          "message": "No more data",
          "expatriates": [],
          "hasMoreData": false
        };
      }

      final List<Expatriate> expatriates = Expatriate.listFromJson(response);

      return {
        "status": "success",
        "message": "Profiles retrieved",
        "expatriates": expatriates,
        "hasMoreData": expatriates.length == _limit
      };
    } catch (e) {
      return {
        "status": "error",
        "message": "Error retrieving expatriates: ${e.toString()}",
        "expatriates": [],
        "hasMoreData": false
      };
    }
  }
}
