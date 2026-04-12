import 'package:flutter/material.dart';
import '../models/feedback_item.dart';

class LastFeedbacksScreen extends StatefulWidget {
  const LastFeedbacksScreen({super.key});

  @override
  State<LastFeedbacksScreen> createState() => _LastFeedbacksScreenState();
}

class _LastFeedbacksScreenState extends State<LastFeedbacksScreen> {
  List<FeedbackItem> feedbacks = [
    FeedbackItem(id: '1', text: '', rating: 1),
    FeedbackItem(id: '2', text: '', rating: 4),
    FeedbackItem(id: '3', text: '', rating: 2),
    FeedbackItem(id: '4', text: '', rating: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: const Text(
                'Last Feedbacks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: const [
                  Text('Edit your feedback', style: TextStyle(fontSize: 15)),
                  SizedBox(width: 6),
                  Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: feedbacks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  FeedbackItem item = feedbacks[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 36, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              return Icon(
                                i < item.rating ? Icons.star : Icons.star_border,
                                color: const Color(0xFFFFCC00),
                                size: 14,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                feedbacks.removeWhere((f) => f.id == item.id);
                              });
                            },
                            child: const Icon(Icons.close, size: 18, color: Colors.black38),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: 0,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: ''),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
            }
          },
        ),
      ),
    );
  }
}
