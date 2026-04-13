import 'package:flutter/material.dart';
import '../models/feedback_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class LastFeedbacksScreen extends StatefulWidget {
  const LastFeedbacksScreen({super.key});

  @override
  State<LastFeedbacksScreen> createState() => _LastFeedbacksScreenState();
}

class _LastFeedbacksScreenState extends State<LastFeedbacksScreen> {
  List<FeedbackItem> feedbacks = [
    FeedbackItem(id: '1', text: 'Great course, very well structured.', rating: 5),
    FeedbackItem(id: '2', text: 'Assignments were challenging but fair.', rating: 4),
    FeedbackItem(id: '3', text: 'Lectures could be more interactive.', rating: 2),
    FeedbackItem(id: '4', text: 'Enjoyed the project-based approach.', rating: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 10),
                  const Text('Last Feedbacks', style: AppTextStyles.screenTitle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                children: const [
                  Text('Edit your feedback', style: AppTextStyles.sectionSubtitle),
                  SizedBox(width: 6),
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.iconMuted),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Sabanci_University_logo.svg/320px-Sabanci_University_logo.svg.png',
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
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
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 36, color: AppColors.iconMuted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.text,
                              style: AppTextStyles.cardBody,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              return Icon(
                                i < item.rating ? Icons.star : Icons.star_border,
                                color: AppColors.starYellow,
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
                            child: const Icon(Icons.close, size: 18, color: AppColors.iconMuted),
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
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.background,
          currentIndex: 0,
          selectedItemColor: Colors.black,
          unselectedItemColor: AppColors.iconMuted,
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
