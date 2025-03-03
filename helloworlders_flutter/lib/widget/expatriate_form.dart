import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/widget/custom_text_field.dart';
import 'package:helloworlders_flutter/widget/date_picker_field.dart';
import 'package:helloworlders_flutter/widget/location_selector.dart';
import 'package:helloworlders_flutter/widget/profile_avatar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ExpatriateForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController ageController;
  final TextEditingController descriptionController;
  final TextEditingController arrivalDateController;
  final TextEditingController departureDateController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final Function(String) onGenderChanged;
  final Function(DateTime) onArrivalDateSelected;
  final Function(DateTime) onDepartureDateSelected;
  final Function(File) onImageSelected;
  final String selectedGender;
  final DateTime? arrivalDate;
  final DateTime? departureDate;
  final File? profileImage;
  final VoidCallback onSubmit;
  final bool isLoading;

  const ExpatriateForm({
    Key? key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.ageController,
    required this.descriptionController,
    required this.arrivalDateController,
    required this.departureDateController,
    required this.latitudeController,
    required this.longitudeController,
    required this.onGenderChanged,
    required this.onArrivalDateSelected,
    required this.onDepartureDateSelected,
    required this.onImageSelected,
    required this.selectedGender,
    this.arrivalDate,
    this.departureDate,
    this.profileImage,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ExpatriateForm> createState() => _ExpatriateFormState();
}

class _ExpatriateFormState extends State<ExpatriateForm> {
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      widget.onImageSelected(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ProfileAvatar(
                imageFile: widget.profileImage,
                radius: 50,
                backgroundColor: colorScheme.primary.withAlpha(70),
                onTap: _pickImage,
                icon: Icons.person_add,
              ),
            ),
            const SizedBox(height: 24),
            LocationSelector(
              latitudeController: widget.latitudeController,
              longitudeController: widget.longitudeController,
            ),
            const SizedBox(height: 16),
            Text(
              'Informations personnelles',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: widget.firstNameController,
              labelText: 'Prénom',
              validator: (value) => value == null || value.isEmpty
                  ? 'Veuillez entrer votre prénom'
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: widget.lastNameController,
              labelText: 'Nom',
              validator: (value) => value == null || value.isEmpty
                  ? 'Veuillez entrer votre nom'
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: widget.emailController,
              labelText: 'Email',
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
            CustomTextField(
              controller: widget.ageController,
              labelText: 'Âge',
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
              value: widget.selectedGender,
              decoration: InputDecoration(
                labelText: 'Genre',
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
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
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
                if (value != null) {
                  widget.onGenderChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),
            DatePickerField(
              controller: widget.arrivalDateController,
              labelText: "Date d'arrivée",
              onDateSelected: widget.onArrivalDateSelected,
              validator: (value) => value == null || value.isEmpty
                  ? "Veuillez sélectionner une date d'arrivée"
                  : null,
            ),
            const SizedBox(height: 16),
            DatePickerField(
              controller: widget.departureDateController,
              labelText: 'Date de départ (optionnel)',
              onDateSelected: widget.onDepartureDateSelected,
              isOptional: true,
              firstDate: widget.arrivalDate,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: widget.descriptionController,
              labelText: 'Description',
              maxLines: 5,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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
    );
  }
}
