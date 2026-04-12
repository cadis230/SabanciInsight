import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  final String email;
  const MainPage({super.key, this.email = ''});

  @override
  Widget build(BuildContext context) {
    String name = 'there';
    if (email.contains('@')) {
      String local = email.split('@')[0];
      if (local.contains('.')) {
        String first = local.split('.')[0];
        if (first.isNotEmpty) {
          name = first[0].toUpperCase() + first.substring(1);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Main Page',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black12, height: 1),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              'Hi, $name!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Container(color: Colors.black12, height: 1),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: const [
                        Icon(Icons.menu_book_outlined, size: 80),
                        SizedBox(height: 12),
                        Text(
                          'Courses',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/feedbacks');
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.people_outline, size: 80),
                        SizedBox(height: 12),
                        Text(
                          'My feedbacks',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: 0,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: ''),
          ],
          onTap: (index) {},
        ),
      ),
    );
  }
}
