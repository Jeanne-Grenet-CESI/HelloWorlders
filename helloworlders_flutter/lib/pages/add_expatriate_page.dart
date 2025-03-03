import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/repositories/expatriate_repository.dart';
import 'package:helloworlders_flutter/services/expatriate_service.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:helloworlders_flutter/widget/expatriate_form.dart';
import 'package:helloworlders_flutter/widget/error_display.dart';
import 'package:helloworlders_flutter/widget/loading_indicator.dart';

class AddExpatriatePage extends StatefulWidget {
  const AddExpatriatePage({super.key});

  @override
  State<AddExpatriatePage> createState() => _AddExpatriatePageState();
}

class _AddExpatriatePageState extends State<AddExpatriatePage> {
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
      TextEditingController(text: "48.8566");
  final TextEditingController _longitudeController =
      TextEditingController(text: "2.3522");

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

  void _handleGenderChanged(String value) {
    setState(() {
      _selectedGender = value;
    });
  }

  void _handleArrivalDateSelected(DateTime date) {
    setState(() {
      _arrivalDate = date;
    });
  }

  void _handleDepartureDateSelected(DateTime date) {
    setState(() {
      _departureDate = date;
    });
  }

  void _handleImageSelected(File image) {
    setState(() {
      _profileImage = image;
    });
  }

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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
            if (_errorMessage.isNotEmpty)
              ErrorDisplay(
                errorMessage: _errorMessage,
                padding: const EdgeInsets.only(bottom: 16),
              ),
            Expanded(
              child: _isLoading && _profileImage == null
                  ? const LoadingIndicator(message: "Chargement...")
                  : ExpatriateForm(
                      formKey: _formKey,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      emailController: _emailController,
                      ageController: _ageController,
                      descriptionController: _descriptionController,
                      arrivalDateController: _arrivalDateController,
                      departureDateController: _departureDateController,
                      latitudeController: _latitudeController,
                      longitudeController: _longitudeController,
                      onGenderChanged: _handleGenderChanged,
                      onArrivalDateSelected: _handleArrivalDateSelected,
                      onDepartureDateSelected: _handleDepartureDateSelected,
                      onImageSelected: _handleImageSelected,
                      selectedGender: _selectedGender,
                      arrivalDate: _arrivalDate,
                      departureDate: _departureDate,
                      profileImage: _profileImage,
                      onSubmit: _submitForm,
                      isLoading: _isLoading,
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
