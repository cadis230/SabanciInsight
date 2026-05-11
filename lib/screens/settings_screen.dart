import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget buildButton({
    required IconData icon,
    required String text,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton.icon(
        onPressed: onTap ?? () {},
        icon: Icon(
          icon,
          color: textColor ?? AppColors.textDark,
          size: 24,
        ),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: AppTextStyles.cardTitle.copyWith(
              color: textColor ?? AppColors.textDark,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.cardBackground,
          alignment: Alignment.centerLeft,
          side: const BorderSide(
            color: AppColors.textLight,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
        centerTitle: true,
        title: const Text(
          'Settings',
          style: AppTextStyles.pageTitle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          child: Column(
            children: [
              buildButton(
                icon: Icons.delete_outline,
                text: 'Delete Account',
                textColor: AppColors.danger,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text('This is a demo action.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              buildButton(
                icon: Icons.logout,
                text: 'Logout',
                onTap: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
              const SizedBox(height: 18),
              buildButton(
                icon: Icons.description_outlined,
                text: 'Edit Uploaded Transcript',
                onTap: () {},
              ),
              const SizedBox(height: 18),
              buildButton(
                icon: Icons.chat_bubble_outline,
                text: 'Contact Us',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.textDark,
        unselectedItemColor: AppColors.textLight,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.main,
            );
          } else if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.profile,
            );
          }
        },
      ),
    );
  }
}