/// Arguments for [AppRoutes.verifyEnrollment].
class VerifyEnrollmentRouteArgs {
  static const defaultCourseCode = 'CS300';
  static const defaultCourseName = 'Algorithms';
  static const defaultArgs = VerifyEnrollmentRouteArgs(
    courseCode: defaultCourseCode,
    courseName: defaultCourseName,
  );

  /// Opens upload flow from Profile (no target course; always replace/save).
  static const profileTranscriptUpload = VerifyEnrollmentRouteArgs(
    courseCode: defaultCourseCode,
    courseName: defaultCourseName,
    fromReviewFlow: false,
    isStandaloneTranscriptUpload: true,
  );

  final String courseCode;
  final String courseName;
  final bool fromReviewFlow;
  final bool isStandaloneTranscriptUpload;

  const VerifyEnrollmentRouteArgs({
    required this.courseCode,
    required this.courseName,
    this.fromReviewFlow = true,
    this.isStandaloneTranscriptUpload = false,
  });
}

/// Arguments for [AppRoutes.specificCourse].
class SpecificCourseRouteArgs {
  final String courseId;
  final String courseTitle;

  const SpecificCourseRouteArgs({
    required this.courseId,
    required this.courseTitle,
  });
}

/// Arguments for [AppRoutes.addReview].
class AddReviewRouteArgs {
  final String courseId;
  final String courseTitle;

  const AddReviewRouteArgs({
    required this.courseId,
    required this.courseTitle,
  });

  static const defaultArgs = AddReviewRouteArgs(
    courseId: VerifyEnrollmentRouteArgs.defaultCourseCode,
    courseTitle: 'CS300 — Algorithms',
  );
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
