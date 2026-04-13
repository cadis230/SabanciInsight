import 'package:flutter/material.dart';
import 'routes.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 📘 COURSE
                const Text(
                  "CS310",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text("Add Review"),

                const SizedBox(height: 20),

                // 📝 COMMENT INPUT
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Write your review here.",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a comment";
                    }
                    if (value.length < 5) {
                      return "Comment too short";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // ⭐ RATING TITLE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Rating",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ⭐ CLICKABLE STARS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 30,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // 🔘 SUBMIT
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      if (rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a rating"),
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Success"),
                          content: const Text("Review submitted!"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // dialog kapanır

                                Navigator.pushNamedAndRemoveUntil(
                                  this.context,
                                  AppRoutes.specificCourse,
                                      (route) => false,
                                );

                                Future.delayed(const Duration(milliseconds: 300), () {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Review submitted successfully"),
                                    ),
                                  );
                                });
                              },
                              child: const Text("OK"),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text("SubmitReview"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔻 BOTTOM NAV
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
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.main,
                  (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.profile,
                  (route) => false,
            );
          }
        },
      ),
    );
  }
}