import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget buildButton({
    required IconData icon,
    required String text,
    required bool isDark,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final effectiveTextColor =
        textColor ?? (isDark ? Colors.white : AppColors.textDark);

    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton.icon(
        onPressed: onTap ?? () {},
        icon: Icon(
          icon,
          color: effectiveTextColor,
          size: 24,
        ),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: AppTextStyles.cardTitle.copyWith(
              color: effectiveTextColor,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0xFF1E1E1E) : AppColors.cardBackground,
          alignment: Alignment.centerLeft,
          side: BorderSide(
            color: isDark ? const Color(0xFF333333) : AppColors.textLight,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget buildToggle({
    required IconData icon,
    required String text,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.cardBackground,
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : AppColors.textLight,
          width: 1.4,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white : AppColors.textDark,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.cardTitle.copyWith(
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: AppTextStyles.pageTitle.copyWith(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          child: Column(
            children: [
              buildToggle(
                icon: Icons.dark_mode_outlined,
                text: 'Dark Mode',
                value: themeProvider.isDarkMode,
                isDark: isDark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
              const SizedBox(height: 18),
              buildButton(
                icon: Icons.delete_outline,
                text: 'Delete Account',
                textColor: AppColors.danger,
                isDark: isDark,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      title: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      content: Text(
                        'This is a demo action.',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
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
                isDark: isDark,
                onTap: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    // Navigate back to the root (AuthWrapper) to reset the auth flow
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 18),
              buildButton(
                icon: Icons.description_outlined,
                text: 'Edit Uploaded Transcript',
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(height: 18),
              buildButton(
                icon: Icons.chat_bubble_outline,
                text: 'Contact Us',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : AppColors.background,
        currentIndex: 1,
        selectedItemColor: isDark ? Colors.white : AppColors.textDark,
        unselectedItemColor: isDark ? Colors.grey : AppColors.textLight,
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