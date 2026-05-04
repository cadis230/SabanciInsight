import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/models/feedback_item.dart';
import '../services/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final _service = FeedbackService();
  StreamSubscription<List<FeedbackItem>>? _sub;

  List<FeedbackItem> feedbacks = [];
  bool isLoading = true;

  FeedbackProvider() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _subscribe(uid);

    FirebaseAuth.instance.authStateChanges().listen((user) {
      _sub?.cancel();
      if (user != null) {
        _subscribe(user.uid);
      } else {
        feedbacks = [];
        isLoading = false;
        notifyListeners();
      }
    });
  }

  void _subscribe(String uid) {
    isLoading = true;
    notifyListeners();
    _sub = _service.getFeedbacks(uid).listen(
      (data) {
        feedbacks = data;
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Firestore stream error: $e');
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> add(String text, double rating) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final item = FeedbackItem(
      id: '',
      text: text,
      rating: rating,
      createdBy: uid,
      createdAt: DateTime.now(),
    );
    await _service.addFeedback(item);
  }

  Future<void> update(FeedbackItem item) => _service.updateFeedback(item);

  Future<void> delete(String id) => _service.deleteFeedback(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
