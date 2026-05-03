import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  bool get isValidEmail =>
      emailController.text.trim().endsWith('@sabanciuniv.edu') &&
          emailController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(context),
              const SizedBox(height: 20),
              const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('Email Address', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('@sabanciuniv.edu'),
              ),
              const Spacer(),
              _primaryButton(
                text: 'Send Code',
                enabled: isValidEmail,
                onTap: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: emailController.text.trim(),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password reset email sent!"),
                      ),
                    );

                    Navigator.pop(context); // login'a geri dön
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? "Error"),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<String> code = [];

  void addDigit(String digit) {
    if (code.length < 5) {
      setState(() => code.add(digit));
    }
  }

  void removeDigit() {
    if (code.isNotEmpty) {
      setState(() => code.removeLast());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isComplete = code.length == 5;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(context),
              const SizedBox(height: 20),
              const Text(
                'Enter 5-digit code',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification code to your email: ${widget.email}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                      (index) => Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      index < code.length ? code[index] : '',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _primaryButton(
                text: 'Continue',
                enabled: isComplete,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreatePasswordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 9) return const SizedBox();
                    if (index == 11) {
                      return _keypadButton(icon: Icons.backspace, onTap: removeDigit);
                    }
                    final number = index == 10 ? '0' : '${index + 1}';
                    return _keypadButton(
                      text: number,
                      onTap: () => addDigit(number),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool get isValid =>
      passwordController.text.length >= 6 &&
          passwordController.text == confirmController.text;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(context),
              const SizedBox(height: 20),
              const Text(
                'Create New Password',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('Password', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'At least 6 characters',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: passwordController.text.length >= 6
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Confirm Password', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                controller: confirmController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Verify password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: confirmController.text.isEmpty
                      ? null
                      : confirmController.text == passwordController.text
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.close, color: Colors.red),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 30),
              _primaryButton(
                text: 'Confirm',
                enabled: isValid,
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Password updated successfully',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'You are being redirected to the home page...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    await Future.delayed(const Duration(seconds: 2));

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.main,
                          (route) => false,
                    );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _backButton(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.arrow_back_ios_new, size: 18),
    ),
  );
}

Widget _primaryButton({
  required String text,
  required VoidCallback onTap,
  required bool enabled,
}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10D5F5),
        foregroundColor: Colors.black,
      ),
      child: Text(text),
    ),
  );
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}

Widget _keypadButton({String? text, IconData? icon, required VoidCallback onTap}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade200,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    onPressed: onTap,
    child: icon != null
        ? Icon(icon)
        : Text(text!, style: const TextStyle(fontSize: 22)),
  );
}
