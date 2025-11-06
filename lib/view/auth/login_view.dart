// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:connectify/view/auth/forgot_password_view.dart';
import 'package:connectify/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:connectify/view/auth/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
                        ),
                      ),
                      const SizedBox(height: 25),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.yellowAccent,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.yellowAccent,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordView(),
                            ),
                          );
                        },
                        child: Text(
                          "forgot password?",
                          style: TextStyle(color: Colors.yellowAccent),
                        ),
                      ),
                      const SizedBox(height: 15),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavigation(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupView(),
                            ),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
