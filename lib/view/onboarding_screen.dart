// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:connectify/view/auth/signup_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpg', fit: BoxFit.cover),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.black.withOpacity(0.35),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() => isLastPage = index == 2);
                    },
                    children: [
                      buildPage(
                        image: 'assets/images/onboard1.jpg',
                        title: "Connect with Friends",
                        description:
                            "Meet new people, share moments, and stay connected with your community.",
                      ),
                      buildPage(
                        image: 'assets/images/onboard2.jpg',
                        title: "Discover New Products",
                        description:
                            "Explore trending items, local stores, and global sellers — all in one app.",
                      ),
                      buildPage(
                        image: 'assets/images/onboard3.jpg',
                        title: "Shop. Chat. Earn.",
                        description:
                            "Buy and sell easily, chat instantly, and grow your influence and income.",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.4),
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 10,
                  ),
                ),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupView(),
                            ),
                          );
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.blueAccent.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        isLastPage ? "Get Started" : "Next",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60), // extra breathing space at bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                image,
                height:
                    MediaQuery.of(context).size.height *
                    0.35, 
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 40),

            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    color: Colors.blueAccent.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
