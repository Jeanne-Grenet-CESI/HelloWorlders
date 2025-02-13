import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/global/utils.dart';
import 'package:helloworlders_flutter/models/expatriate.dart';

class ExpatriateResume extends StatelessWidget {
  final Expatriate expatriate;

  const ExpatriateResume({super.key, required this.expatriate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          expatriate.imageRepository != null && expatriate.imageFileName != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    Global.getImagePath(
                        expatriate.imageRepository!, expatriate.imageFileName!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.account_circle,
                  size: 60,
                ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${expatriate.firstName} ${expatriate.lastName}', // Utilisation du nom de l'expatrié
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Pays : ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    TextSpan(
                      text: expatriate.country, // Pays de l'expatrié
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Date d’arrivée : ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    TextSpan(
                      text: expatriate.arrivalDate != null
                          ? Global.formatDate(expatriate.arrivalDate!)
                          : 'Non renseigné', // Date d’arrivée
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Date de départ : ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    TextSpan(
                      text: expatriate.departureDate != null
                          ? Global.formatDate(expatriate.departureDate!)
                          : 'Non renseigné', // Date de départ
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
