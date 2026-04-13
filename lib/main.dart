import 'package:flutter/material.dart';
import 'screens/routes.dart';

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
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}