import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/feedback_provider.dart';
import 'models/feedback_item.dart';
import 'routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

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
    final newVal = !_sortByRating;
    setState(() => _sortByRating = newVal);
    await prefs.setBool(_kSortKey, newVal);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedbackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reviews = List<FeedbackItem>.from(provider.feedbacks);
    if (_sortByRating) {
      reviews.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
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
                    'My Reviews',
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'Reviews you have submitted for courses',
                style: AppTextStyles.sectionSubtitle.copyWith(
                  color: isDark ? Colors.white70 : AppColors.iconMuted,
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reviews.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'No reviews yet. Go to a course page to add one.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    isDark ? Colors.white54 : AppColors.iconMuted,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: reviews.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = reviews[index];
                            return Card(
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (item.courseId != null)
                                            Text(
                                              item.courseId!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white54
                                                    : AppColors.iconMuted,
                                              ),
                                            ),
                                          Text(
                                            item.text,
                                            style:
                                                AppTextStyles.cardBody.copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
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
