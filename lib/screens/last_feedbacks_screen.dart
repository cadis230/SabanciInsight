import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/feedback_provider.dart';
import 'models/feedback_item.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'profile_screen.dart';

const _kSortKey = 'feedbacks_sort_by_rating';

class LastFeedbacksScreen extends StatefulWidget {
  const LastFeedbacksScreen({super.key});

  @override
  State<LastFeedbacksScreen> createState() => _LastFeedbacksScreenState();
}

class _LastFeedbacksScreenState extends State<LastFeedbacksScreen> {
  bool _sortByRating = false;

  @override
  void initState() {
    super.initState();
    _loadSortPref();
  }

  Future<void> _loadSortPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _sortByRating = prefs.getBool(_kSortKey) ?? false);
  }

  Future<void> _toggleSort() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _sortByRating = !_sortByRating);
    await prefs.setBool(_kSortKey, _sortByRating);
  }

  void _showFeedbackDialog(FeedbackItem? existing) {
    final textController = TextEditingController(text: existing?.text ?? '');
    double rating = existing?.rating ?? 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Feedback' : 'Edit Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write your feedback...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setDlg(() => rating = (i + 1).toDouble()),
                    child: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: AppColors.starYellow,
                      size: 28,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) return;
                final provider = context.read<FeedbackProvider>();
                if (existing == null) {
                  await provider.add(text, rating);
                } else {
                  await provider.update(FeedbackItem(
                    id: existing.id,
                    text: text,
                    rating: rating,
                    createdBy: existing.createdBy,
                    createdAt: existing.createdAt,
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedbackProvider>();
    final feedbacks = List<FeedbackItem>.from(provider.feedbacks);
    if (_sortByRating) feedbacks.sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFeedbackDialog(null),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Image.asset('assets/images/app_icon.png', width: 32, height: 32),
                  const SizedBox(width: 10),
                  const Text('Last Feedbacks', style: AppTextStyles.screenTitle),
                  const Spacer(),
                  GestureDetector(
                    onTap: _toggleSort,
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 18,
                            color: _sortByRating ? Colors.black : AppColors.iconMuted),
                        const SizedBox(width: 4),
                        Text(
                          _sortByRating ? 'By rating' : 'By date',
                          style: TextStyle(
                            fontSize: 12,
                            color: _sortByRating ? Colors.black : AppColors.iconMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : feedbacks.isEmpty
                      ? const Center(child: Text('No feedbacks yet. Tap + to add one.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: feedbacks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = feedbacks[index];
                            return GestureDetector(
                              onTap: () => _showFeedbackDialog(item),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 36, color: AppColors.iconMuted),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(item.text,
                                            style: AppTextStyles.cardBody),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < item.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: AppColors.starYellow,
                                            size: 14,
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => context
                                            .read<FeedbackProvider>()
                                            .delete(item.id),
                                        child: const Icon(Icons.close,
                                            size: 18, color: AppColors.iconMuted),
                                      ),
                                    ],
                                  ),
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
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
