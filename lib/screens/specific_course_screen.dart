import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import 'models/feedback_item.dart';
import 'enrollment_route_args.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';
import '../services/ai_service.dart';
import '../services/enrollment_verification_service.dart';
import '../services/transcript_course_extractor.dart';

class SpecificCourseScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const SpecificCourseScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<SpecificCourseScreen> createState() => _SpecificCourseScreenState();
}

class _SpecificCourseScreenState extends State<SpecificCourseScreen> {
  final AiService _aiService = AiService();
  String? _aiInsight;
  bool _aiLoading = false;
  String _lastReviewsKey = '';

  Future<void> _refreshInsight(List<FeedbackItem> reviews) async {
    final key = reviews.map((r) => r.text).join('||');
    if (key == _lastReviewsKey) return;
    _lastReviewsKey = key;

    setState(() => _aiLoading = true);

    try {
      final avg = reviews.isEmpty
          ? 0.0
          : reviews.fold(0.0, (s, r) => s + r.rating) / reviews.length;

      final insight = await _aiService.generateCourseInsights(
        courseTitle: widget.courseTitle,
        reviews: reviews.map((r) => r.text).toList(),
        avgRating: avg,
      );
      if (mounted) setState(() => _aiInsight = insight);
    } catch (_) {
      if (mounted) setState(() => _aiInsight = 'Could not load AI insights.');
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Widget _buildStarRow(double rating) {
    final filled = rating.round().clamp(0, 5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (i) => Icon(
          i < filled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildReviewCard(FeedbackItem item, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : AppColors.cardBackground,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF333333) : AppColors.textLight,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.person,
                    color: isDark ? Colors.white : AppColors.textDark,
                    size: 28),
                const Spacer(),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.star, color: Colors.amber, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                color: isDark ? Colors.white70 : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF121212) : AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.courseTitle,
          style: AppTextStyles.pageTitle.copyWith(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
      body: StreamBuilder<List<FeedbackItem>>(
        stream: FeedbackService().getReviewsByCourse(widget.courseId),
        builder: (context, snapshot) {
          final reviews = snapshot.data ?? [];
          final avg = reviews.isEmpty
              ? 0.0
              : reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;

          if (snapshot.hasData && reviews.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _refreshInsight(reviews);
            });
          }

          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 86,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : AppColors.cardBackground,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333333)
                                  : AppColors.textLight,
                              width: 1.4,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                reviews.isEmpty
                                    ? 'No ratings'
                                    : 'Avg ${avg.toStringAsFixed(1)}',
                                style: AppTextStyles.sectionTitle.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildStarRow(avg),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 58,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : AppColors.cardBackground,
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF333333)
                                    : AppColors.textLight,
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'View Syllabus',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Card(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFDCEBFA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF333333)
                            : AppColors.textLight,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 6),
                              Text(
                                'AI-Generated Insights',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _aiLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Text(
                                  reviews.isEmpty
                                      ? 'Add reviews to see AI insights.'
                                      : (_aiInsight ?? 'Analyzing reviews...'),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.textDark,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : reviews.isEmpty
                            ? Center(
                                child: Text(
                                  'No reviews yet. Be the first!',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textLight,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: reviews.length,
                                itemBuilder: (context, index) =>
                                    _buildReviewCard(reviews[index], isDark),
                              ),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please sign in to add a review.'),
                            ),
                          );
                          return;
                        }
                        try {
                          final service = EnrollmentVerificationService();
                          final items = await service.listForUser(user.uid);
                          final merged =
                              EnrollmentVerificationService.mergedCourseCodes(
                                  items);
                          if (!context.mounted) return;
                          if (TranscriptCourseExtractor.listContainsCourse(
                            merged,
                            widget.courseId,
                          )) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.addReview,
                              arguments: AddReviewRouteArgs(
                                courseId: widget.courseId,
                                courseTitle: widget.courseTitle,
                              ),
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.verifyEnrollment,
                              arguments: VerifyEnrollmentRouteArgs(
                                courseCode: widget.courseId,
                                courseName: widget.courseTitle,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not check your transcript. Try again.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.add_circle,
                        color: isDark ? Colors.white : AppColors.textDark,
                        size: 34,
                      ),
                      label: Text(
                        'ADD REVIEW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : AppColors.cardBackground,
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF333333)
                              : AppColors.textLight,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : AppColors.cardBackground,
        currentIndex: 0,
        selectedItemColor: isDark ? Colors.white : AppColors.textDark,
        unselectedItemColor: isDark ? Colors.grey : AppColors.textLight,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.main);
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
