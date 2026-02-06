// ignore_for_file: deprecated_member_use

import 'package:connectify/services/auth_services.dart';
import 'package:connectify/widgets/app_glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (emailController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Email is required",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    await AuthServices().resetPassword(
      emailController.text.trim(),
    );

    setState(() => isLoading = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter your email",
              prefixIcon: const Icon(Icons.email),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Send Reset Link"),
          ),
        ],
      ),
    );
  }
}
