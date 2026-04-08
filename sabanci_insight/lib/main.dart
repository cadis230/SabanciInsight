import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SabanciInsightApp());
}

class SabanciInsightApp extends StatelessWidget {
  const SabanciInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SabanciInsight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2B5CE6)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}