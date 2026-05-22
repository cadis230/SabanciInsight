import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/models/feedback_item.dart';

/// Shared Firestore cache so Gemini is not called again when reviews are unchanged.
class CourseAiCacheService {
  static const _collection = 'course_ai_summaries';

  final _col = FirebaseFirestore.instance.collection(_collection);

  /// Stable fingerprint: count, ratings, and text for every review (sorted by id).
  static String buildFingerprint(List<FeedbackItem> reviews) {
    final sorted = List<FeedbackItem>.from(reviews)
      ..sort((a, b) => a.id.compareTo(b.id));
    final parts = <String>['count:${sorted.length}'];
    for (final r in sorted) {
      parts.add('${r.id}|${r.rating}|${r.text.trim()}');
    }
    return parts.join(';;');
  }

  Future<String?> getCachedSummary(String courseId, String fingerprint) async {
    final doc = await _col.doc(courseId).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    if (data['reviewsFingerprint'] != fingerprint) return null;

    final summary = data['summary'] as String?;
    if (summary == null || summary.isEmpty) return null;

    return summary;
  }

  Future<void> saveSummary({
    required String courseId,
    required String fingerprint,
    required String summary,
    required int reviewCount,
  }) async {
    await _col.doc(courseId).set({
      'courseId': courseId,
      'reviewsFingerprint': fingerprint,
      'summary': summary,
      'reviewCount': reviewCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
