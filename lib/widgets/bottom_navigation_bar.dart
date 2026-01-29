// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../view/home/home_view.dart';
import '../view/categories/categories_view.dart';
import '../view/bookings/bookings_view.dart';
import '../view/profile/profile_view.dart';

class BottomNavigation extends StatefulWidget {
  final String uid; 

  const BottomNavigation({super.key, required this.uid});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late final Stream<QuerySnapshot> _bookingNotificationStream;

  @override
  void initState() {
    super.initState();

    _bookingNotificationStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: widget.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home_rounded,
      Icons.category_rounded,
      Icons.book_online_rounded,
      Icons.person_rounded,
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeView(),
          CategoriesView(),
          BookingsView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            final isActive = _selectedIndex == index;

            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.deepPurple.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icons[index],
                      size: 26,
                      color: isActive ? Colors.deepPurple : Colors.grey,
                    ),

                    if (index == 2)
                      StreamBuilder<QuerySnapshot>(
                        stream: _bookingNotificationStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const SizedBox();
                          }

                          return Positioned(
                            top: -3,
                            right: -3,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
