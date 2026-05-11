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
}
