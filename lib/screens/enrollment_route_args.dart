/// Arguments for [AppRoutes.verifyEnrollment].
class VerifyEnrollmentRouteArgs {
  final String courseCode;
  final String courseName;
  final bool fromReviewFlow;

  const VerifyEnrollmentRouteArgs({
    required this.courseCode,
    required this.courseName,
    this.fromReviewFlow = true,
  });
}

/// Arguments for [AppRoutes.verificationSuccess] after Firestore create.
class VerificationSuccessRouteArgs {
  final String documentId;
  final String courseCode;
  final String courseName;
  final String fileName;
  final String userEmail;
  final DateTime recordedAt;
  final List<String> extractedCourseCodes;

  const VerificationSuccessRouteArgs({
    required this.documentId,
    required this.courseCode,
    required this.courseName,
    required this.fileName,
    required this.userEmail,
    required this.recordedAt,
    this.extractedCourseCodes = const [],
  });
}
