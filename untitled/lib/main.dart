import 'package:flutter/material.dart';
import 'package:untitled/screens/menu_screen.dart';
import 'screens/menu_screen.dart';

void main() => runApp(const HangmanApp());

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'monospace'),
          bodyMedium: TextStyle(fontFamily: 'monospace'),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}