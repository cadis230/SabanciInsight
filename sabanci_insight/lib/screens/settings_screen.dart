import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget buildButton({
    required IconData icon,
    required String text,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: OutlinedButton.icon(
          onPressed: onTap ?? () {},
          icon: Icon(icon, color: textColor ?? Colors.black),
          label: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.black,
              fontSize: 20,
            ),
          ),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            buildButton(
              icon: Icons.delete_outline,
              text: 'Delete Account',
              textColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('This is a demo action'),
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
            buildButton(
              icon: Icons.logout,
              text: 'Logout',
            ),
            buildButton(
              icon: Icons.edit,
              text: 'Edit Uploaded Transcript',
            ),
            buildButton(
              icon: Icons.message,
              text: 'Contact Us',
            ),
          ],
        ),
      ),
    );
  }
}