import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'models/enrollment_verification_item.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Transcript',
          style: AppTextStyles.pageTitle.copyWith(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see your transcript.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('enrollment_verifications')
                  .where('createdBy', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transcript uploaded yet.',
                            style: AppTextStyles.cardTitle.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload your transcript while verifying a course to see it here.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyText.copyWith(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Sort locally to find the latest transcript without needing a Firestore index
                final docs = snapshot.data!.docs.toList();
                docs.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime); // Latest first
                });

                final latestDoc = docs.first;
                final verificationItem = EnrollmentVerificationItem.fromFirestore(latestDoc);
                final courses = verificationItem.extractedCourseCodes;

                if (courses.isEmpty) {
                  return const Center(child: Text('No courses found in the transcript.'));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Uploaded: ${verificationItem.fileName}',
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${verificationItem.createdAt?.toString().split('.')[0] ?? 'N/A'}',
                            style: AppTextStyles.bodyText.copyWith(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        itemCount: courses.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(
                              Icons.school_outlined,
                              color: isDark ? Colors.white70 : AppColors.primary,
                            ),
                            title: Text(
                              courses[index],
                              style: AppTextStyles.cardTitle.copyWith(
                                color: isDark ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
