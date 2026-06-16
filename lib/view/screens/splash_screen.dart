// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:connectify/services/app_preferences.dart';
import 'package:connectify/view/auth/login_view.dart';
import 'package:connectify/view/screens/onboarding_screen.dart';
import 'package:connectify/widgets/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Run animation + auth/prefs check in parallel
    _determineStartScreen();
  }

  Future<void> _determineStartScreen() async {
    // Wait for both the minimum splash duration AND the checks together
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _getStartScreen(),
    ]);

    if (!mounted) return;

    final destination = results[1] as Widget;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  /// Decides which screen to go to:
  /// 1. Never seen onboarding → OnboardingScreen
  /// 2. Seen onboarding, not logged in → LoginView
  /// 3. Seen onboarding, logged in → BottomNavBar (Home)
  Future<Widget> _getStartScreen() async {
    // Check onboarding first (fast local read)
    final seenOnboarding = await AppPreferences.hasSeenOnboarding();
    if (!seenOnboarding) {
      return const OnboardingScreen();
    }

    // Check Firebase Auth state
    final user = FirebaseAuth.instance.currentUser;

    // Reload to ensure token is still valid
    if (user != null) {
      try {
        await user.reload();
        final refreshed = FirebaseAuth.instance.currentUser;
        if (refreshed != null) {
          return BottomNavigation(uid: refreshed.uid);
        }
      } catch (_) {
        // Token expired or account deleted — fall through to login
      }
    }

    return const LoginView();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP ACCENT LINE 
            Container(
              height: 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.black],
                ),
              ),
            ),

            // ── LOGO + NAME 
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.handyman_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Connectify',
                            style: TextStyle(
                              fontFamily: 'Pacifico',
                              fontSize: 40,
                              color: Colors.black,
                              letterSpacing: 1.5,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Find. Book. Get It Done.',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── LOADING DOTS + FOOTER 
            FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  children: [
                    const _LoadingDots(),
                    const SizedBox(height: 20),
                    const Text(
                      'Home services, simplified',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ANIMATED LOADING DOTS 
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value =
                ((_dotController.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity =
                value < 0.5 ? value * 2 : (1.0 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.deepPurple
                    .withOpacity(0.3 + opacity * 0.7),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}