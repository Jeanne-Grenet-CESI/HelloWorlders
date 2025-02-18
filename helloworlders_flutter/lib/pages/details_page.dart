import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
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
                child: expatriate.imageRepository != null &&
                        expatriate.imageFileName != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          Global.getImagePath(expatriate.imageRepository!,
                              expatriate.imageFileName!),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.account_circle, size: 100),
              ),
              const SizedBox(height: 30),
              Text(
                "Informations personnelles",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(context, "Prénom", expatriate.firstName),
              _buildInfoRow(context, "Nom", expatriate.lastName),
              _buildInfoRow(
                  context, "Genre", expatriate.gender ?? "Non spécifié"),
              _buildInfoRow(context, "Age", "${expatriate.age} ans"),
              _buildInfoRow(context, "Nom d'utilisateur", expatriate.username),
              const SizedBox(height: 20),
              Text(
                "Informations de contact",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(context, "Email", expatriate.email),
              const SizedBox(height: 20),
              Text(
                "Localisation",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(context, "Pays", expatriate.country),
              _buildInfoRow(
                  context, "Latitude", expatriate.latitude.toString()),
              _buildInfoRow(
                  context, "Longitude", expatriate.longitude.toString()),
              const SizedBox(height: 20),
              Text(
                "Dates",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(context, "Date d'arrivée",
                  Global.formatDate(expatriate.arrivalDate)),
              if (expatriate.departureDate != null)
                _buildInfoRow(context, "Date de départ",
                    Global.formatDate(expatriate.departureDate!)),
              const SizedBox(height: 20),
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$label : ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
