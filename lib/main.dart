import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/routes.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print(" Firebase initialized");

  runApp(const SabanciInsightApp());
}

class SabanciInsightApp extends StatelessWidget {
  const SabanciInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SabanciInsight',
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: AppRoutes.routes,
    );
  }
}