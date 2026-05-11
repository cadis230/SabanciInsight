import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/feedback_provider.dart';
import 'models/feedback_item.dart';
import 'routes.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';

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
    if (!mounted) return;

    final newSortByRating = !_sortByRating;
    setState(() => _sortByRating = newSortByRating);

    await prefs.setBool(_kSortKey, newSortByRating);
  }

  void _showFeedbackDialog(FeedbackItem? existing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textController = TextEditingController(text: existing?.text ?? '');
    double rating = existing?.rating ?? 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text(
              existing == null ? 'Add Feedback' : 'Edit Feedback',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your feedback...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    filled: true,
                    fillColor:
                        isDark ? const Color(0xFF121212) : Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            isDark ? const Color(0xFF333333) : Colors.black26,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            isDark ? const Color(0xFF333333) : Colors.black26,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black,
                      ),
                    ),
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
                    await provider.update(
                      FeedbackItem(
                        id: existing.id,
                        text: text,
                        rating: rating,
                        createdBy: existing.createdBy,
                        createdAt: existing.createdAt,
                      ),
                    );
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(existing == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    ).then((_) => textController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedbackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final feedbacks = List<FeedbackItem>.from(provider.feedbacks);
    if (_sortByRating) {
      feedbacks.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFeedbackDialog(null),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.black,
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
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Last Feedbacks',
                    style: AppTextStyles.screenTitle.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _toggleSort,
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          size: 18,
                          color: _sortByRating
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.grey : AppColors.iconMuted),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _sortByRating ? 'By rating' : 'By date',
                          style: TextStyle(
                            fontSize: 12,
                            color: _sortByRating
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark ? Colors.grey : AppColors.iconMuted),
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
                children: [
                  Text(
                    'Edit your feedback',
                    style: AppTextStyles.sectionSubtitle.copyWith(
                      color: isDark ? Colors.white70 : AppColors.iconMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: isDark ? Colors.grey : AppColors.iconMuted,
                  ),
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
                      ? Center(
                          child: Text(
                            'No feedbacks yet. Tap + to add one.',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: feedbacks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = feedbacks[index];

                            return GestureDetector(
                              onTap: () => _showFeedbackDialog(item),
                              child: Card(
                                color: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF333333)
                                        : AppColors.border,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 36,
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors.iconMuted,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.text,
                                          style:
                                              AppTextStyles.cardBody.copyWith(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
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
                                        child: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: isDark
                                              ? Colors.white70
                                              : AppColors.iconMuted,
                                        ),
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
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF333333) : AppColors.border,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor:
              isDark ? const Color(0xFF1E1E1E) : AppColors.background,
          currentIndex: 0,
          selectedItemColor: isDark ? Colors.white : Colors.black,
          unselectedItemColor: isDark ? Colors.grey : AppColors.iconMuted,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30),
              label: '',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                (_) => false,
              );
            } else if (index == 1) {
              Navigator.pushNamed(context, AppRoutes.profile);
            }
          },
        ),
      ),
    );
  }
}