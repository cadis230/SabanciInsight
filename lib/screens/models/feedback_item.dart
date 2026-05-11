import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackItem {
  final String id;
  final String text;
  final double rating;
  final String createdBy;
  final DateTime? createdAt;
  final String? courseId;

  FeedbackItem({
    required this.id,
    required this.text,
    required this.rating,
    required this.createdBy,
    this.createdAt,
    this.courseId,
  });

  factory FeedbackItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackItem(
      id: doc.id,
      text: data['text'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      courseId: data['courseId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'rating': rating,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      if (courseId != null) 'courseId': courseId!,
    };
  }
}
