// ignore_for_file: deprecated_member_use

import 'package:connectify/services/auth_services.dart';
import 'package:connectify/view/auth/forgot_password_view.dart';
import 'package:connectify/view/auth/signup_view.dart';
import 'package:connectify/widgets/app_glass_scaffold.dart';
import 'package:connectify/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Email and password required",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    final user = await AuthServices().login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (user != null && mounted) {
      Fluttertoast.showToast(
        msg: "Login successful!",
        backgroundColor: Colors.green,
      );

      final currentUser = AuthServices().currentUser;
      if (currentUser == null) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BottomNavigation(uid: currentUser.uid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Welcome Back",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),

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

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordView(),
                  ),
                );
              },
              child: const Text("Forgot password?"),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isLoading ? null : _login,
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
                : const Text("Login"),
          ),

          const SizedBox(height: 20),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupView()),
              );
            },
            child: const Text("Don't have an account? Sign Up"),
          ),
        ],
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
