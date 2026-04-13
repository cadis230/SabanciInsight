
import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';

class SpecificCourseScreen extends StatelessWidget {
  const SpecificCourseScreen({super.key});

  Widget buildStarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
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
  }) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.textLight,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppColors.textDark,
                  size: 28,
                ),
                const Spacer(),
                Text(
                  rating,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'CS 300  Algorithms',
          style: AppTextStyles.pageTitle,
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
                        color: AppColors.cardBackground,
                        border: Border.all(
                          color: AppColors.textLight,
                          width: 1.4,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Avg 3.0',
                            style: AppTextStyles.sectionTitle,
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
                          backgroundColor: AppColors.cardBackground,
                          side: const BorderSide(
                            color: AppColors.textLight,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'View Syllabus',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.cardTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                color: const Color(0xFFDCEBFA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(
                    color: AppColors.textLight,
                    width: 1.0,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'AI-Generated Insights',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Students consistently mention high workload. Grading is strict.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyText,
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
                      comment:
                      'I took this course from Saima hoca. The course is very informative and well-structured. However, the workload is quite heavy.',
                    ),
                    buildReviewCard(
                      rating: '4.5',
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
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.textDark,
                    size: 34,
                  ),
                  label: const Text(
                    'ADD REVIEW',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    side: const BorderSide(
                      color: AppColors.textLight,
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
        backgroundColor: AppColors.cardBackground,
        currentIndex: 0,
        selectedItemColor: AppColors.textDark,
        unselectedItemColor: AppColors.textLight,
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
