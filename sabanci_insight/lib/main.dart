import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/main_page.dart';
import 'screens/last_feedbacks_screen.dart';
import 'screens/verify_enrollment_screen.dart';
import 'screens/verification_successful_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/feedbacks': (context) => const LastFeedbacksScreen(),
        '/verify-enrollment': (context) => const VerifyEnrollmentScreen(),
        '/verification-successful': (context) =>
            const VerificationSuccessfulScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final email = settings.arguments as String? ?? '';
          return MaterialPageRoute(builder: (_) => MainPage(email: email));
        }
        return null;
      },
    );
  }
}
