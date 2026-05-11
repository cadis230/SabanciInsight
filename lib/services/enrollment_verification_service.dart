import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/models/enrollment_verification_item.dart';

class EnrollmentVerificationService {
  final _col =
      FirebaseFirestore.instance.collection('enrollment_verifications');

  /// Returns the new document id.
  Future<String> create(EnrollmentVerificationItem item) async {
    final doc = await _col.add(item.toCreateMap());
    return doc.id;
  }

  Future<void> deleteAllForUser(String userId) async {
    final snapshots = await _col.where('createdBy', isEqualTo: userId).get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
