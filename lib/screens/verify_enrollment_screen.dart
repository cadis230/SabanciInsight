import 'package:flutter/material.dart';
import 'routes.dart';

class VerifyEnrollmentScreen extends StatelessWidget {
  final bool fromReviewFlow;

  const VerifyEnrollmentScreen({
    super.key,
    this.fromReviewFlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFD1D5DB);
    final primaryText = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(isDark: isDark),
                  const SizedBox(height: 20),
                  _ProgressStepsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload your transcript to verify you have completed this course. '
                    'We only accept official PDF exports.',
                    style: TextStyle(
                      color: secondaryText,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  UploadBox(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 14),
                  _RequirementsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.verificationSuccess,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Upload and Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "I'll do this later",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;

  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(22),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Enrollment',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Course: CS301 - Algorithms',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStepsCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const _ProgressStepsCard({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          StepItem(
            stepNumber: 1,
            title: 'Upload Transcript',
            subtitle: 'Official PDF from Banner',
            isActive: true,
            showConnector: true,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          StepItem(
            stepNumber: 2,
            title: 'AI Verification',
            subtitle: 'Checking course history',
            showConnector: true,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          StepItem(
            stepNumber: 3,
            title: 'Write Review',
            subtitle: 'Share your experience',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class StepItem extends StatelessWidget {
  const StepItem({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.isActive = false,
    this.showConnector = false,
  });

  final int stepNumber;
  final String title;
  final String subtitle;
  final bool isDark;
  final bool isActive;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final circleColor = isActive ? const Color(0xFF2196F3) : const Color(0xFFBFDBFE);
    final textColor = isActive
        ? (isDark ? Colors.white : const Color(0xFF111827))
        : (isDark ? Colors.white70 : const Color(0xFF6B7280));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (showConnector) ...[
                const SizedBox(height: 6),
                Container(
                  width: 1.5,
                  height: 30,
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFD1D5DB),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UploadBox extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const UploadBox({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.upload_file_rounded, size: 56, color: Color(0xFF2196F3)),
          const SizedBox(height: 6),
          Text(
            'Tap to select PDF',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'or drag and drop here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const _RequirementsCard({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements:',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          RequirementItem(
            icon: Icons.picture_as_pdf_rounded,
            text: 'Format: PDF only',
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          RequirementItem(
            icon: Icons.badge_rounded,
            text: 'Must show your name and Student ID',
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          RequirementItem(
            icon: Icons.lock_outline_rounded,
            text: 'Data is encrypted and used for verification only',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class RequirementItem extends StatelessWidget {
  const RequirementItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white70 : const Color(0xFF374151),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white70 : const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}