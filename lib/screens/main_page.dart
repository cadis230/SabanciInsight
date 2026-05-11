import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String name = 'there';
    final trimmed = email.trim();

    if (trimmed.contains('@')) {
      final local = trimmed.split('@')[0];
      final first = local.contains('.') ? local.split('.')[0] : local;
      if (first.isNotEmpty) {
        name = first[0].toUpperCase() + first.substring(1);
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/app_icon.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(
              'SabancıInsight',
              style: AppTextStyles.navTitle.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? const Color(0xFF333333) : AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Text(
              'Hi, $name!',
              style: AppTextStyles.greeting.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Sabanci_University_logo.svg/320px-Sabanci_University_logo.svg.png',
              height: 40,
              alignment: Alignment.centerLeft,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Container(
            color: isDark ? const Color(0xFF333333) : AppColors.border,
            height: 1,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.courseReview,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 80,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Courses',
                          style: AppTextStyles.featureLabel.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.feedbacks,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'My feedbacks',
                          style: AppTextStyles.featureLabel.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            if (index == 1) {
              Navigator.pushNamed(context, AppRoutes.profile);
            }
          },
        ),
      ),
    );
  }
}