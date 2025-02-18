import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/pages/home_page.dart';
import 'package:helloworlders_flutter/pages/login_page.dart';
import 'package:helloworlders_flutter/pages/register_page.dart';
import 'package:helloworlders_flutter/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      routes: <String, WidgetBuilder>{
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
