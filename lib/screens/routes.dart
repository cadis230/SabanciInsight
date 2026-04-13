import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'main_page.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'course_review_screen.dart';
import 'specific_course_screen.dart';
import 'add_review_screen.dart';
import 'last_feedbacks_screen.dart';
import 'forgot_password_flow.dart';
import 'verify_enrollment_screen.dart';
import 'verification_successful_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';
  static const profile = '/profile';
  static const settings = '/settings';
  static const courseReview = '/course-review';
  static const specificCourse = '/specific-course';
  static const addReview = '/add-review';
  static const feedbacks = '/feedbacks';
  static const forgotPassword = '/forgot-password';
  static const verifyEnrollment = '/verify-enrollment';
  static const verificationSuccess = '/verification-success';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    main: (_) => const MainPage(),
    profile: (_) => const ProfileScreen(),
    settings: (_) => const SettingsScreen(),
    courseReview: (_) => const CourseReviewScreen(),
    specificCourse: (_) => const SpecificCourseScreen(),
    addReview: (_) => const AddReviewScreen(),
    feedbacks: (_) => const LastFeedbacksScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    verifyEnrollment: (_) => const VerifyEnrollmentScreen(),
    verificationSuccess: (_) => const VerificationSuccessfulScreen(),
  };
}