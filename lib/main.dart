import 'package:flutter/material.dart';
import 'package:edumanager/theme.dart';
import 'package:edumanager/screens/auth/login_screen.dart';

void main() {
  runApp(const EduManagerApp());
}

class EduManagerApp extends StatelessWidget {
  const EduManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduManager - Gestion de Cours Particuliers',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
