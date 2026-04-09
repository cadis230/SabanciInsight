import 'package:flutter/material.dart';
import '../screens/course_review_screen.dart';
import '../screens/add_review_screen.dart';

class AppRoutes {
  static const String courseReview = '/';
  static const String addReview = '/add-review';

  static Map<String, WidgetBuilder> routes = {
    courseReview: (context) => const CourseReviewScreen(),
    addReview: (context) => const AddReviewScreen(),
  };
}