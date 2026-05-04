import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/models/feedback_item.dart';

class FeedbackService {
  final _col = FirebaseFirestore.instance.collection('feedbacks');

  Stream<List<FeedbackItem>> getFeedbacks(String uid) {
    return _col
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FeedbackItem.fromFirestore).toList());
  }

  Future<void> addFeedback(FeedbackItem item) {
    return _col.add(item.toMap());
  }

  Future<void> updateFeedback(FeedbackItem item) {
    return _col.doc(item.id).update({'text': item.text, 'rating': item.rating});
  }

  Future<void> deleteFeedback(String id) {
    return _col.doc(id).delete();
  }
}
