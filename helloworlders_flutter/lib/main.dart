import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/pages/login_page.dart';
import 'package:helloworlders_flutter/theme/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginPage(),
    );
  }
}
