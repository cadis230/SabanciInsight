import 'package:flutter/material.dart';
import 'enrollment_route_args.dart';
import 'routes.dart';

class CourseReviewScreen extends StatelessWidget {
  const CourseReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextField(
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search",
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Course",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                buildCourseItem(context, isDark, 'CS300', 'CS 300  Algorithms'),
                buildCourseItem(context, isDark, 'CS301', 'CS 301  Data Structures'),
                buildCourseItem(context, isDark, 'CS310', 'CS 310  Mobile App Dev'),
                const SizedBox(height: 20),
                Text(
                  "Instructors",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                buildInstructorItem(isDark),
                buildInstructorItem(isDark),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Featured Course",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "https://picsum.photos/200",
                          width: 200,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        currentIndex: 0,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: isDark ? Colors.grey : Colors.grey,
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

  Widget buildCourseItem(BuildContext context, bool isDark, String courseId, String courseTitle) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.specificCourse,
          arguments: SpecificCourseRouteArgs(
            courseId: courseId,
            courseTitle: courseTitle,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              "assets/images/course.png",
              width: 40,
              height: 40,
              color: isDark ? Colors.white : null,
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                Icon(Icons.star,
                    size: 16, color: isDark ? Colors.amber : Colors.black),
                Icon(Icons.star,
                    size: 16, color: isDark ? Colors.amber : Colors.black),
                Icon(Icons.star,
                    size: 16, color: isDark ? Colors.amber : Colors.black),
                Icon(Icons.star,
                    size: 16, color: isDark ? Colors.amber : Colors.black),
                Icon(Icons.star_border,
                    size: 16, color: isDark ? Colors.amber : Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInstructorItem(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: isDark ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 10),
          Text(
            "Username",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}