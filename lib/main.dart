import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jiji Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.dark,
          background: const Color(0xFF131314),
        ),
        scaffoldBackgroundColor: const Color(0xFF131314),
        useMaterial3: true,
      ),
      // Using the key provided by user in gemini_api.dart
      home: HomeScreen(apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''),
    );
  }
}
