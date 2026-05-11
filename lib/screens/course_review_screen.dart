import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'enrollment_route_args.dart';
import 'routes.dart';

class CourseReviewScreen extends StatefulWidget {
  const CourseReviewScreen({super.key});

  @override
  State<CourseReviewScreen> createState() => _CourseReviewScreenState();
}

class _CourseReviewScreenState extends State<CourseReviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _extractCourses(QuerySnapshot snapshot) {
    final Map<String, String> courses = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final courseCode = (data['courseId'] ?? doc.id).toString().trim();
      final courseName = (data['courseTitle'] ?? courseCode).toString().trim();

      if (courseCode.isNotEmpty) {
        courses[courseCode] = courseName.isNotEmpty ? courseName : courseCode;
      }

      final extracted = data['extractedCourseCodes'];

      if (extracted is List) {
        for (final item in extracted) {
          final code = item.toString().trim();
          if (code.isNotEmpty && !courses.containsKey(code)) {
            courses[code] = code;
          }
        }
      }
    }

    final list = courses.entries
        .map((e) => {
      'id': e.key,
      'title': e.value,
    })
        .toList();

    list.sort((a, b) => a['id']!.compareTo(b['id']!));

    if (_searchText.trim().isEmpty) {
      return list;
    }

    final query = _searchText.toLowerCase();

    return list.where((course) {
      final id = course['id']!.toLowerCase();
      final title = course['title']!.toLowerCase();

      return id.contains(query) || title.contains(query);
    }).toList();
  }

  void _openSpecificCourse(Map<String, String> course) {
    Navigator.pushNamed(
      context,
      AppRoutes.specificCourse,
      arguments: SpecificCourseRouteArgs(
        courseId: course['id']!,
        courseTitle: course['title']!,
      ),
    );
  }

  Widget _buildCourseItem(
      BuildContext context,
      bool isDark,
      Map<String, String> course,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openSpecificCourse(course),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? Colors.black : Colors.white,
              child: Icon(
                Icons.menu_book,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['id']!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course['title']!,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white54 : Colors.black54,
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
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        title: const Text('Courses'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Search course',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  filled: true,
                  fillColor:
                  isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Something went wrong:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final courses = _extractCourses(snapshot.data!);

                    if (courses.isEmpty) {
                      return Center(
                        child: Text(
                          'No courses found.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return _buildCourseItem(
                          context,
                          isDark,
                          courses[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        currentIndex: 0,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: Colors.grey,
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
            Navigator.pushNamed(
              context,
              AppRoutes.profile,
            );
          }
        },
      ),
    );
  }
}