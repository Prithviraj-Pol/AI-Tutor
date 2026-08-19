import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TutorApp());
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Tutor - Kannada',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
