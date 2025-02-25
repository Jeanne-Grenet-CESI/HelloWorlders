import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/repositories/expatriate_repository.dart';
import 'package:helloworlders_flutter/services/expatriate_service.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class AddExpatriatePage extends StatefulWidget {
  const AddExpatriatePage({super.key});

  @override
  State<AddExpatriatePage> createState() => _AddExpatriatePageState();
}

class _AddExpatriatePageState extends State<AddExpatriatePage> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _latitudeController =
      TextEditingController(text: "48.8566"); // Paris default
  final TextEditingController _longitudeController =
      TextEditingController(text: "2.3522");

  // State variables
  DateTime? _arrivalDate;
  DateTime? _departureDate;
  String _selectedGender = 'men';
  File? _profileImage;
  bool _isLoading = false;
  String _errorMessage = '';
  late ExpatriateRepository _expatriateRepository;

  @override
  void initState() {
    super.initState();
    _expatriateRepository = ExpatriateRepository(
      apiExpatriateService: ApiExpatriateService(),
    );
  }

  // Helper to create styled form fields
  InputDecoration _getInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      floatingLabelStyle:
          TextStyle(color: Theme.of(context).colorScheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  // Show snackbar helper
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

  // Get current location
  Future<void> _getCurrentPosition() async {
    setState(() => _isLoading = true);

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(
              'L\'autorisation de localisation est nécessaire pour obtenir votre position actuelle.',
              isError: true);
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
            'L\'autorisation de localisation est définitivement refusée. Veuillez l\'activer dans les paramètres de l\'application.',
            isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _isLoading = false;
      });

      _showSnackBar('Position actuelle récupérée avec succès!');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Erreur lors de la récupération de la position: ${e.toString()}';
      });
      _showSnackBar('Erreur: $_errorMessage', isError: true);
    }
  }

  // Select image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context, bool isArrivalDate) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        isArrivalDate ? (_arrivalDate ?? now) : (_departureDate ?? now);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isArrivalDate) {
          _arrivalDate = picked;
          _arrivalDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _departureDate = picked;
          _departureDateController.text =
              DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  // Submit form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await _expatriateRepository.createExpatriate(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          arrivalDate: _arrivalDate ?? DateTime.now(),
          departureDate: _departureDate,
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          age: int.parse(_ageController.text),
          gender: _selectedGender,
          description: _descriptionController.text,
          profileImage: _profileImage,
        );

        setState(() => _isLoading = false);

        if (result["status"] == "success") {
          _showSnackBar(result["message"]);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showSnackBar(result["message"], isError: true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        _showSnackBar('Erreur: $_errorMessage', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color lightGreen = colorScheme.primary.withOpacity(0.2);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Créer un profil expatrié",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Show error message if necessary
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.red.shade100,
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Form
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile image
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: lightGreen,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: colorScheme.primary,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Geographic coordinates
                            Text(
                              'Coordonnées géographiques',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _getCurrentPosition,
                                icon: const Icon(Icons.my_location, size: 18),
                                label: const Text(
                                    'Utiliser ma position actuelle',
                                    style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: colorScheme.secondary),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Coordonnées par défaut: Paris, France',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Informations personelles',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Form fields
                            TextFormField(
                              controller: _firstNameController,
                              decoration: _getInputDecoration('Prénom'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Veuillez entrer votre prénom'
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _lastNameController,
                              decoration: _getInputDecoration('Nom'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Veuillez entrer votre nom'
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _emailController,
                              decoration: _getInputDecoration('Email'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Veuillez entrer un email valide';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _ageController,
                              decoration: _getInputDecoration('Âge'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre âge';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Veuillez entrer un nombre valide';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: _getInputDecoration('Genre'),
                              icon: Icon(Icons.arrow_drop_down,
                                  color: colorScheme.primary),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'men',
                                  child: Text('Homme'),
                                ),
                                DropdownMenuItem(
                                  value: 'women',
                                  child: Text('Femme'),
                                ),
                                DropdownMenuItem(
                                  value: 'other',
                                  child: Text('Non spécifié'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _arrivalDateController,
                              decoration: _getInputDecoration(
                                "Date d'arrivée",
                                suffixIcon: Icon(Icons.calendar_today,
                                    color: colorScheme.primary, size: 20),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, true),
                              validator: (value) => value == null ||
                                      value.isEmpty
                                  ? "Veuillez sélectionner une date d'arrivée"
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _departureDateController,
                              decoration: _getInputDecoration(
                                'Date de départ (optionnel)',
                                suffixIcon: Icon(Icons.calendar_today,
                                    color: colorScheme.primary, size: 20),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, false),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _descriptionController,
                              decoration: _getInputDecoration('Description'),
                              maxLines: 5,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Veuillez entrer une description'
                                      : null,
                            ),
                            const SizedBox(height: 30),

                            // Submit button
                            Center(
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                ),
                                child: const Text(
                                  'Créer le profil',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _arrivalDateController.dispose();
    _departureDateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}
