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
import 'enrollment_route_args.dart';
import 'verify_enrollment_screen.dart';
import 'verification_successful_screen.dart';
import 'transcript_screen.dart';

class AppRoutes {
  static const splash = '/splash';
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
  static const transcript = '/transcript';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    main: (_) => const MainPage(),
    profile: (_) => const ProfileScreen(),
    settings: (_) => const SettingsScreen(),
    courseReview: (_) => const CourseReviewScreen(),
    specificCourse: (context) {
      final raw = ModalRoute.of(context)?.settings.arguments;
      final args = raw is SpecificCourseRouteArgs ? raw : null;
      return SpecificCourseScreen(
        courseId: args?.courseId ?? 'CS300',
        courseTitle: args?.courseTitle ?? 'CS 300  Algorithms',
      );
    },
    addReview: (context) {
      final raw = ModalRoute.of(context)?.settings.arguments;
      final args = raw is AddReviewRouteArgs ? raw : AddReviewRouteArgs.defaultArgs;
      return AddReviewScreen(
        courseId: args.courseId,
        courseTitle: args.courseTitle,
      );
    },
    feedbacks: (_) => const LastFeedbacksScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    verifyEnrollment: (context) {
      final raw = ModalRoute.of(context)?.settings.arguments;
      final args = raw is VerifyEnrollmentRouteArgs
          ? raw
          : VerifyEnrollmentRouteArgs.defaultArgs;
      return VerifyEnrollmentScreen(
        courseCode: args.courseCode,
        courseName: args.courseName,
        fromReviewFlow: args.fromReviewFlow,
        isStandaloneTranscriptUpload: args.isStandaloneTranscriptUpload,
      );
    },
    verificationSuccess: (context) {
      final raw = ModalRoute.of(context)?.settings.arguments;
      final args =
          raw is VerificationSuccessRouteArgs ? raw : null;
      return VerificationSuccessfulScreen(args: args);
    },
    transcript: (_) => const TranscriptScreen(),
  };
}
