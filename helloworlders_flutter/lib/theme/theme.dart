import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Définition des couleurs
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF5A803D),
        onPrimary: Colors.white,
        secondary: Color(0xFFD57E7E),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      ),
    );
  }
}
