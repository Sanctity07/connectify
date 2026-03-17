// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/view/home/active_bookings_sheet.dart';
import 'package:connectify/view/home/location_sheet.dart';
import 'package:connectify/view/home/provider_card.dart';
import 'package:connectify/view/profile/profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const List<String> _categories = [
    'All',
    'Cleaner',
    'IT Solutions',
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'Gardening',
    'Tutoring',
  ];

  int _activeIndex = 0;
  String? _username;
  String? _userPhoto;
  String _searchQuery = '';
  String? _savedLocation;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _username = 'Guest';
        _userPhoto = '';
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _username = data['username'] ?? user.displayName ?? 'Guest';
        _userPhoto = data['profilePhotoUrl'] ?? '';
        _savedLocation = data['location'] ?? '';
      });
    } else {
      setState(() {
        _username = user.displayName ?? 'Guest';
        _userPhoto = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _username == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── TOP ROW ───────────────────────────────────
                    _TopRow(
                      username: _username!,
                      userPhoto: _userPhoto ?? '',
                      savedLocation: _savedLocation,
                      onProfileTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileView()),
                      ).then((_) => _loadUser()),
                      onLocationTap: () => showLocationSheet(
                        context,
                        currentLocation: _savedLocation,
                        onLocationSaved: (loc) =>
                            setState(() => _savedLocation = loc),
                      ),
                      onBookingsTap: () =>
                          showActiveBookingsSheet(context),
                    ),

                    const SizedBox(height: 24),

                    // ── HEADLINE ──────────────────────────────────
                    const Text(
                      'Smart Home',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const Text(
                      'Smooth Services',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Urbanist',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── SEARCH ────────────────────────────────────
                    _SearchBar(
                      onChanged: (v) => setState(
                          () => _searchQuery = v.toLowerCase().trim()),
                    ),

                    const SizedBox(height: 16),

                    // ── CATEGORY CHIPS ────────────────────────────
                    _CategoryChips(
                      categories: _categories,
                      activeIndex: _activeIndex,
                      onTap: (i) => setState(() => _activeIndex = i),
                    ),

                    const SizedBox(height: 16),

                    // ── PROVIDER LIST ─────────────────────────────
                    Expanded(
                      child: _ProviderList(
                        categories: _categories,
                        activeIndex: _activeIndex,
                        searchQuery: _searchQuery,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── TOP ROW ───────────────────────────────────────────────────────────────────
class _TopRow extends StatelessWidget {
  final String username;
  final String userPhoto;
  final String? savedLocation;
  final VoidCallback onProfileTap;
  final VoidCallback onLocationTap;
  final VoidCallback onBookingsTap;

  const _TopRow({
    required this.username,
    required this.userPhoto,
    required this.savedLocation,
    required this.onProfileTap,
    required this.onLocationTap,
    required this.onBookingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile pill
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: userPhoto.isNotEmpty
                      ? NetworkImage(userPhoto)
                      : const AssetImage('assets/images/onboard1.jpg')
                          as ImageProvider,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      username,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Row(
          children: [
            // Location button
            GestureDetector(
              onTap: onLocationTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: (savedLocation?.isNotEmpty ?? false)
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                    if (savedLocation != null &&
                        savedLocation!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        savedLocation!.length > 10
                            ? '${savedLocation!.substring(0, 10)}…'
                            : savedLocation!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Bag icon with live badge
            _BookingsBadge(onTap: onBookingsTap),
          ],
        ),
      ],
    );
  }
}

// ── BOOKINGS BADGE ────────────────────────────────────────────────────────────
class _BookingsBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _BookingsBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: uid == null
          ? null
          : FirebaseFirestore.instance
              .collection('bookings')
              .where('customerId', isEqualTo: uid)
              .where('status',
                  whereIn: ['pending', 'accepted', 'started'])
              .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20),
                if (count > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
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
    );
  }
}

// ── SEARCH BAR ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search for services (e.g plumber)',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CATEGORY CHIPS ────────────────────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _CategoryChips({
    required this.categories,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isActive = index == activeIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── PROVIDER LIST ─────────────────────────────────────────────────────────────
class _ProviderList extends StatelessWidget {
  final List<String> categories;
  final int activeIndex;
  final String searchQuery;

  const _ProviderList({
    required this.categories,
    required this.activeIndex,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('providers')
          .where('status', isEqualTo: 'verified')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final skills =
              List<String>.from(data['skills'] ?? []);

          final matchesCategory = activeIndex == 0
              ? true
              : skills.any((s) =>
                  s.toLowerCase() ==
                  categories[activeIndex].toLowerCase());

          final matchesSearch = searchQuery.isEmpty
              ? true
              : skills.any(
                  (s) => s.toLowerCase().contains(searchQuery));

          return matchesCategory && matchesSearch;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No results for "$searchQuery"'
                      : 'No providers available',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data =
                filtered[index].data() as Map<String, dynamic>;
            final providerId = filtered[index].id;

            return ProviderCard(
              providerId: providerId,
              data: data,
              skills: (data['skills'] as List<dynamic>?)
                      ?.join(', ') ??
                  '',
              online: data['online'] ?? false,
              ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
              ratingCount: data['ratingCount'] ?? 0,
              photoUrl: data['profilePhotoUrl'] ?? '',
              bio: data['bio'] ?? '',
            );
          },
        );
      },
    );
  }
}