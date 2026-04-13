import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';

class MainPage extends StatelessWidget {
  final String email;
  const MainPage({super.key, this.email = ''});

  @override
  Widget build(BuildContext context) {
    String name = 'there';
    final String trimmedEmail = email.trim();
    if (trimmedEmail.contains('@')) {
      final String local = trimmedEmail.split('@')[0];
      final String first = local.contains('.') ? local.split('.')[0] : local;
      if (first.isNotEmpty) {
        name = first[0].toUpperCase() + first.substring(1);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_icon.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text('SabancıInsight', style: AppTextStyles.navTitle),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Text(
              'Hi, $name!',
              style: AppTextStyles.greeting,
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
          Container(color: AppColors.border, height: 1),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.courseReview,
                      );
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.menu_book_outlined, size: 80),
                        SizedBox(height: 12),
                        Text('Courses', style: AppTextStyles.featureLabel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.feedbacks,
                      );
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.people_outline, size: 80),
                        SizedBox(height: 12),
                        Text('My feedbacks', style: AppTextStyles.featureLabel),
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
            if (index == 1) {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
            }
          },
        ),
      ),
    );
  }
}