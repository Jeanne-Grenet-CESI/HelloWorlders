import 'dart:io';

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

  Future<Map<String, dynamic>> createExpatriate({
    required String firstName,
    required String lastName,
    required String email,
    required DateTime arrivalDate,
    required DateTime? departureDate,
    required double latitude,
    required double longitude,
    required int age,
    required String gender,
    required String description,
    File? profileImage,
  }) async {
    try {
      // Validate and set default coordinates if not provided
      final double validLatitude =
          _validateCoordinate(latitude, 48.8566); // Paris default
      final double validLongitude =
          _validateCoordinate(longitude, 2.3522); // Paris default

      // Convertir l'image en base64 si elle existe
      String? base64Image;
      if (profileImage != null) {
        base64Image = await apiExpatriateService.imageToBase64(profileImage);
      }

      // Préparer les données pour l'API avec des valeurs par défaut sécurisées
      final Map<String, dynamic> expatriateData = {
        "Firstname": firstName.trim(),
        "Lastname": lastName.trim(),
        "Email": email.trim(),
        "ArrivalDate": arrivalDate.toIso8601String().split('T')[0],
        "DepartureDate": departureDate?.toIso8601String().split('T')[0],
        "Latitude": validLatitude,
        "Longitude": validLongitude,
        "Age": age,
        "Gender": gender,
        "Description": description.trim(),
      };

      // Ajouter l'image si elle existe
      if (base64Image != null) {
        expatriateData["Image"] = base64Image;
      }

      // Appeler l'API
      final response =
          await apiExpatriateService.createExpatriate(expatriateData);

      if (response["statusCode"] == 200 &&
          response["body"]["status"] == "success") {
        return {
          "status": "success",
          "message": response["body"]["message"],
          "id": response["body"]["id"],
        };
      } else {
        return {
          "status": "error",
          "message":
              response["body"]["message"] ?? "Erreur lors de la création",
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Erreur lors de la création: ${e.toString()}",
      };
    }
  }

  // Helper method to validate coordinates
  double _validateCoordinate(double coordinate, double defaultValue) {
    // Check if coordinate is within valid range (-90 to 90 for latitude, -180 to 180 for longitude)
    if (coordinate.isNaN ||
        (coordinate > 90 || coordinate < -90) && coordinate.abs() < 180) {
      // If it looks like longitude was passed as latitude or vice versa, swap
      return defaultValue;
    }
    return coordinate;
  }
}
