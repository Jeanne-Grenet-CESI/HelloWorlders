import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_text_field.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateSelected;
  final bool isOptional;

  const DatePickerField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.isOptional = false,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    final DateTime now = DateTime.now();
    final DateTime initialDateValue = initialDate ?? now;
    final DateTime firstDateValue = firstDate ?? DateTime(2000);
    final DateTime lastDateValue = lastDate ?? DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDateValue,
      firstDate: firstDateValue,
      lastDate: lastDateValue,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = dateFormat.format(picked);
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      validator: validator ??
          (isOptional
              ? null
              : (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez sélectionner une date";
                  }
                  return null;
                }),
      readOnly: true,
      onTap: () => _selectDate(context),
      suffixIcon: Icon(
        Icons.calendar_today,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }
}
