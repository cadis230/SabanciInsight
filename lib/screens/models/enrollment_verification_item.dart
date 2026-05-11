import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore-backed enrollment verification (metadata only; PDF is not stored).
class EnrollmentVerificationItem {
  final String id;
  final String courseCode;
  final String courseName;
  final String fileName;
  final int fileSizeBytes;
  final String createdBy;
  final DateTime? createdAt;
  final String status;
  /// Course codes read from PDF text + any user-added codes (normalized, e.g. CS300).
  final List<String> extractedCourseCodes;

  EnrollmentVerificationItem({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.fileName,
    required this.fileSizeBytes,
    required this.createdBy,
    this.createdAt,
    this.status = 'verified',
    this.extractedCourseCodes = const [],
  });

  factory EnrollmentVerificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawCodes = data['extractedCourseCodes'];
    final codes = rawCodes is List
        ? rawCodes.map((e) => e.toString()).toList()
        : <String>[];

    return EnrollmentVerificationItem(
      id: doc.id,
      courseCode: data['courseCode'] as String? ?? '',
      courseName: data['courseName'] as String? ?? '',
      fileName: data['fileName'] as String? ?? '',
      fileSizeBytes: (data['fileSizeBytes'] as num?)?.toInt() ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'verified',
      extractedCourseCodes: codes,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'status': status,
      'extractedCourseCodes': extractedCourseCodes,
    };
  }
}
