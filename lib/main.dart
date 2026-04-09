import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const UniBuddyApp());
}

class UniBuddyApp extends StatelessWidget {
  const UniBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniBuddy',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      initialRoute: AppRoutes.courseReview,
      routes: AppRoutes.routes,
    );
  }
}