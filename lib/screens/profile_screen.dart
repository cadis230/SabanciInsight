import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: AppTextStyles.pageTitle,
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
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Jane Doe',
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transcript page will be connected here.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    side: const BorderSide(
                      color: AppColors.textLight,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'View my transcript',
                    style: AppTextStyles.cardTitle,
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
                    backgroundColor: AppColors.cardBackground,
                    side: const BorderSide(
                      color: AppColors.textLight,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Settings',
                    style: AppTextStyles.cardTitle,
                  ),
                ),
              ),
              const Spacer(),
              BottomNavigationBar(
                backgroundColor: AppColors.cardBackground,
                selectedItemColor: AppColors.textDark,
                unselectedItemColor: AppColors.textLight,
                currentIndex: 1,
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
            ],
          ),
        ),
      ),
    );
  }
}