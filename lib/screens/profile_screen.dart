import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'enrollment_route_args.dart';
import 'routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: AppTextStyles.pageTitle.copyWith(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : AppColors.cardBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 70,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'Profile',
                style: AppTextStyles.pageTitle.copyWith(
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.transcript,
                    );
                  },
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
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'View my transcript',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.verifyEnrollment,
                      arguments: VerifyEnrollmentRouteArgs.profileTranscriptUpload,
                    );
                  },
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
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Upload / update transcript',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.settings,
                    );
                  },
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
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Settings',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : AppColors.cardBackground,
        selectedItemColor: isDark ? Colors.white : AppColors.textDark,
        unselectedItemColor: isDark ? Colors.grey : AppColors.textLight,
        currentIndex: 1,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.main,
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