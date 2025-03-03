import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'custom_text_field.dart';

class LocationSelector extends StatefulWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final Function(double latitude, double longitude)? onLocationSelected;
  final Function(String)? onErrorOccurred;

  const LocationSelector({
    Key? key,
    required this.latitudeController,
    required this.longitudeController,
    this.onLocationSelected,
    this.onErrorOccurred,
  }) : super(key: key);

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  bool _isLoading = false;

  Future<void> _getCurrentPosition() async {
    setState(() => _isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleError(
              'L\'autorisation de localisation est nécessaire pour obtenir votre position actuelle.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _handleError(
            'L\'autorisation de localisation est définitivement refusée. Veuillez l\'activer dans les paramètres de l\'application.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        widget.latitudeController.text = position.latitude.toString();
        widget.longitudeController.text = position.longitude.toString();
        _isLoading = false;
      });

      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(position.latitude, position.longitude);
      }

      _showSnackBar('Position actuelle récupérée avec succès!');
    } catch (e) {
      _handleError(
          'Erreur lors de la récupération de la position: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    setState(() => _isLoading = false);
    if (widget.onErrorOccurred != null) {
      widget.onErrorOccurred!(message);
    }
    _showSnackBar('Erreur: $message', isError: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red : Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coordonnées géographiques',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _getCurrentPosition,
            icon: _isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.my_location, size: 18),
            label: Text(
              _isLoading ? 'Chargement...' : 'Utiliser ma position actuelle',
              style: const TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Coordonnées par défaut: Paris, France',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: widget.latitudeController,
                labelText: 'Latitude',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: widget.longitudeController,
                labelText: 'Longitude',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
