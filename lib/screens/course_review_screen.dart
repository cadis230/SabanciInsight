import 'package:flutter/material.dart';
import 'routes.dart';

class CourseReviewScreen extends StatelessWidget {
  const CourseReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Course",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                buildCourseItem(context),
                buildCourseItem(context),
                buildCourseItem(context),
                const SizedBox(height: 20),
                const Text(
                  "Instructors",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                buildInstructorItem(),
                buildInstructorItem(),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Featured Course",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.network(
                        "https://picsum.photos/200",
                        width: 200,
                        height: 120,
                        fit: BoxFit.cover,
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

      // 🔻 BOTTOM NAV (wireframe gibi)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
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

  // 🔧 COURSE ITEM (GRİ BLOK + STAR)
  Widget buildCourseItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.specificCourse,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [

            // GRI BOX (placeholder)
            Image.asset(
              "assets/images/course.png",
              width: 40,
              height: 40,
            ),



            const SizedBox(width: 10),

            // STARS
            Row(
              children: const [
                Icon(Icons.star, size: 16),
                Icon(Icons.star, size: 16),
                Icon(Icons.star, size: 16),
                Icon(Icons.star, size: 16),
                Icon(Icons.star_border, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 INSTRUCTOR ITEM
  Widget buildInstructorItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.person),
          SizedBox(width: 10),
          Text("Username"),
        ],
      ),
    );
  }
}