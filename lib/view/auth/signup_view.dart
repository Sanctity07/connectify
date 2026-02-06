// ignore_for_file: deprecated_member_use

import 'package:connectify/services/auth_services.dart';
import 'package:connectify/view/auth/login_view.dart';
import 'package:connectify/widgets/app_glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "All fields are required",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    final user = await AuthServices().signup(
      username: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (user != null && mounted) {
      Fluttertoast.showToast(
        msg: "Signup successful! Verify your email.",
        backgroundColor: Colors.green,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassScaffold(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),

            _inputField(
              controller: nameController,
              hint: "Full Name",
              icon: Icons.person,
            ),
            const SizedBox(height: 16),

            _inputField(
              controller: emailController,
              hint: "Email",
              icon: Icons.email,
            ),
            const SizedBox(height: 16),

            _inputField(
              controller: passwordController,
              hint: "Password",
              icon: Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: isLoading ? null : _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
