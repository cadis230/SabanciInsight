import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/models/enrollment_verification_item.dart';
import 'transcript_course_extractor.dart';

class EnrollmentVerificationService {
  final _col =
      FirebaseFirestore.instance.collection('enrollment_verifications');

  /// Returns the new document id.
  Future<String> create(EnrollmentVerificationItem item) async {
    final doc = await _col.add(item.toCreateMap());
    return doc.id;
  }

  /// Deletes all prior verifications for [userId] and writes [item] in one
  /// batch so the store never ends up empty if the write fails.
  Future<String> replaceTranscriptForUser(
    String userId,
    EnrollmentVerificationItem item,
  ) async {
    final snapshots = await _col.where('createdBy', isEqualTo: userId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    final newRef = _col.doc();
    batch.set(newRef, item.toCreateMap());
    await batch.commit();
    return newRef.id;
  }

  Future<List<EnrollmentVerificationItem>> listForUser(String userId) async {
    final snapshots = await _col.where('createdBy', isEqualTo: userId).get();
    return snapshots.docs
        .map((d) => EnrollmentVerificationItem.fromFirestore(d))
        .toList();
  }

  /// Unique normalized course codes from every verification document.
  static List<String> mergedCourseCodes(List<EnrollmentVerificationItem> items) {
    final set = <String>{};
    for (final i in items) {
      for (final c in i.extractedCourseCodes) {
        set.add(TranscriptCourseExtractor.normalizeCourseCode(c));
      }
    }
    final out = set.toList()..sort();
    return out;
  }

  /// Newest verification that explicitly lists [courseCode] in its extracted codes.
  static EnrollmentVerificationItem? latestItemContainingCourse(
    List<EnrollmentVerificationItem> items,
    String courseCode,
  ) {
    if (items.isEmpty) return null;
    final sorted = List<EnrollmentVerificationItem>.from(items)
      ..sort((a, b) {
        final at = a.createdAt;
        final bt = b.createdAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
    for (final i in sorted) {
      if (TranscriptCourseExtractor.listContainsCourse(
        i.extractedCourseCodes,
        courseCode,
      )) {
        return i;
      }
    }
    return null;
  }

  Future<void> deleteAllForUser(String userId) async {
    final snapshots = await _col.where('createdBy', isEqualTo: userId).get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
