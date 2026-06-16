// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/view/notifications/notifications_view.dart';
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

  // Use the actual current user uid (in case uid was passed as '' from splash)
  String get _uid =>
      widget.uid.isNotEmpty
          ? widget.uid
          : AuthServices().currentUser?.uid ?? '';

  /// Unread notification count stream for the current user
  Stream<int> get _unreadNotifStream => _uid.isEmpty
      ? Stream.value(0)
      : FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _uid)
          .snapshots()
          // Count unread client-side to avoid composite index
          .map((snap) => snap.docs.where((d) {
                final data = d.data();
                return data['read'] == false;
              }).length);

  /// Pending booking count — shows for providers AND customers
  Stream<int> get _pendingBookingStream {
    if (_uid.isEmpty) return Stream.value(0);
    // Check if provider — if no provider doc, treat as customer
    return FirebaseFirestore.instance
        .collection('providers')
        .doc(_uid)
        .snapshots()
        .asyncExpand((provSnap) {
      final isProvider = provSnap.exists &&
          (provSnap.data()?['status'] ?? '') == 'verified';

      if (isProvider) {
        return FirebaseFirestore.instance
            .collection('bookings')
            .where('providerId', isEqualTo: _uid)
            .where('status', isEqualTo: 'pending')
            .snapshots()
            .map((s) => s.docs.length);
      } else {
        return FirebaseFirestore.instance
            .collection('bookings')
            .where('customerId', isEqualTo: _uid)
            .where('status', whereIn: ['pending', 'accepted', 'started'])
            .snapshots()
            .map((s) => s.docs.length);
      }
    });
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
          children: [
            // Regular nav items
            ...List.generate(4, (index) {
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

                      // Bookings badge (index 2)
                      if (index == 2)
                        StreamBuilder<int>(
                          stream: _pendingBookingStream,
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            if (count == 0) return const SizedBox();
                            return Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: count > 9 ? 18 : 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    count > 9 ? '9+' : '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

            // Notification bell — separate from page nav
            StreamBuilder<int>(
              stream: _unreadNotifStream,
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsView()),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          count > 0
                              ? Icons.notifications_rounded
                              : Icons.notifications_outlined,
                          size: 26,
                          color: count > 0 ? Colors.deepPurple : Colors.grey,
                        ),
                        if (count > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: count > 9 ? 18 : 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
