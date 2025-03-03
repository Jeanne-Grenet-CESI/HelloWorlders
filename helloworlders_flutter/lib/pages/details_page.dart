import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:helloworlders_flutter/widget/profile_avatar.dart';
import 'package:helloworlders_flutter/widget/detail_info_row.dart';
import 'package:helloworlders_flutter/global/utils.dart';

class DetailPage extends StatelessWidget {
  final Expatriate expatriate;

  const DetailPage({super.key, required this.expatriate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "${expatriate.firstName} ${expatriate.lastName}",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ProfileAvatar(
                  imageRepository: expatriate.imageRepository,
                  imageFileName: expatriate.imageFileName,
                  initials: "${expatriate.firstName} ${expatriate.lastName}",
                  radius: 50,
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle(context, "Informations personnelles"),
              const SizedBox(height: 10),
              DetailInfoRow(label: "Prénom", value: expatriate.firstName),
              DetailInfoRow(label: "Nom", value: expatriate.lastName),
              DetailInfoRow(
                  label: "Genre", value: expatriate.gender ?? "Non spécifié"),
              DetailInfoRow(label: "Age", value: "${expatriate.age} ans"),
              DetailInfoRow(
                  label: "Nom d'utilisateur", value: expatriate.username),
              const SizedBox(height: 20),
              _buildSectionTitle(context, "Informations de contact"),
              const SizedBox(height: 10),
              DetailInfoRow(label: "Email", value: expatriate.email),
              const SizedBox(height: 20),
              _buildSectionTitle(context, "Localisation"),
              const SizedBox(height: 10),
              DetailInfoRow(label: "Pays", value: expatriate.country),
              DetailInfoRow(
                  label: "Latitude", value: expatriate.latitude.toString()),
              DetailInfoRow(
                  label: "Longitude", value: expatriate.longitude.toString()),
              const SizedBox(height: 20),
              _buildSectionTitle(context, "Dates"),
              const SizedBox(height: 10),
              DetailInfoRow(
                  label: "Date d'arrivée",
                  value: Global.formatDate(expatriate.arrivalDate)),
              if (expatriate.departureDate != null)
                DetailInfoRow(
                    label: "Date de départ",
                    value: Global.formatDate(expatriate.departureDate!)),
              const SizedBox(height: 20),
              _buildSectionTitle(context, "Description"),
              const SizedBox(height: 10),
              Text(
                expatriate.description ?? "Aucune description disponible",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
