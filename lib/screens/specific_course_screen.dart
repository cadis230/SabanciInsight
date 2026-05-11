import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';

class SpecificCourseScreen extends StatelessWidget {
  const SpecificCourseScreen({super.key});

  Widget buildStarRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.star, color: Colors.amber, size: 22),
        Icon(Icons.star, color: Colors.amber, size: 22),
        Icon(Icons.star, color: Colors.amber, size: 22),
        Icon(Icons.star, color: Colors.grey, size: 22),
        Icon(Icons.star, color: Colors.grey, size: 22),
      ],
    );
  }

  Widget buildReviewCard({
    required String comment,
    required String rating,
    required bool isDark,
  }) {
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
                Icon(
                  Icons.person,
                  color: isDark ? Colors.white : AppColors.textDark,
                  size: 28,
                ),
                const Spacer(),
                Text(
                  rating,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment,
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
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
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
          'CS 300  Algorithms',
          style: AppTextStyles.pageTitle.copyWith(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                            'Avg 3.0',
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          buildStarRow(),
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
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFDCEBFA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF333333) : AppColors.textLight,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'AI-Generated Insights',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Students consistently mention high workload. Grading is strict.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyText.copyWith(
                          color: isDark ? Colors.white70 : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    buildReviewCard(
                      rating: '4.5',
                      isDark: isDark,
                      comment:
                          'I took this course from Saima hoca. The course is very informative and well-structured. However, the workload is quite heavy.',
                    ),
                    buildReviewCard(
                      rating: '4.5',
                      isDark: isDark,
                      comment:
                          'This course requires consistent effort throughout the semester. The grading of Kamer hoca is strict.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.verifyEnrollment,
                    );
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
                      color:
                          isDark ? const Color(0xFF333333) : AppColors.textLight,
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
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.main,
            );
          } else if (index == 1) {
            Navigator.pushNamed(
              context,
              AppRoutes.profile,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}