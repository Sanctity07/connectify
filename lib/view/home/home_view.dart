// ignore_for_file: deprecated_member_use

import 'package:connectify/view/bookings/booking_form_view.dart';
import 'package:connectify/view/profile/profile_view.dart';
import 'package:connectify/view/provider/provider_public_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<String> categories = [
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

  int activeIndex = 0;
  String? username;
  String? userPhoto;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          username = data['username'] ?? user.displayName ?? 'Guest';
          userPhoto = data['profilePhotoUrl'] ?? '';
        });
      } else {
        setState(() {
          username = user.displayName ?? 'Guest';
          userPhoto = '';
        });
      }
    } else {
      setState(() {
        username = 'Guest';
        userPhoto = '';
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
          child: username == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── TOP ROW ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileView()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
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
                                  backgroundImage: (userPhoto != null &&
                                          userPhoto!.isNotEmpty)
                                      ? NetworkImage(userPhoto!)
                                      : const AssetImage(
                                              'assets/images/onboard1.jpg')
                                          as ImageProvider,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Welcome',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey)),
                                    Text(
                                      username!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.location_on_outlined),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.shopping_bag_outlined),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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

                    // ── SEARCH ───────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                          const Icon(Icons.search_rounded,
                              color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() =>
                                  searchQuery = v.toLowerCase().trim()),
                              decoration: const InputDecoration(
                                hintText:
                                    'Search for services (e.g plumber)',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── CATEGORY CHIPS ───────────────────────────────────
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final isActive = index == activeIndex;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => activeIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── PROVIDERS ────────────────────────────────────────
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('providers')
                            .where('status', isEqualTo: 'verified')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data!.docs;

                          final filtered = docs.where((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>;
                            final skills = List<String>.from(
                                data['skills'] ?? []);

                            final matchesCategory = activeIndex == 0
                                ? true
                                : skills.any((s) =>
                                    s.toLowerCase() ==
                                    categories[activeIndex]
                                        .toLowerCase());

                            final matchesSearch = searchQuery.isEmpty
                                ? true
                                : skills.any((s) => s
                                    .toLowerCase()
                                    .contains(searchQuery));

                            return matchesCategory && matchesSearch;
                          }).toList();

                          if (filtered.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 48,
                                      color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    searchQuery.isNotEmpty
                                        ? 'No results for "$searchQuery"'
                                        : 'No providers available',
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final data = filtered[index].data()
                                  as Map<String, dynamic>;
                              final providerId = filtered[index].id;
                              final skills = (data['skills']
                                          as List<dynamic>?)
                                      ?.join(', ') ??
                                  '';
                              final online =
                                  data['online'] ?? false;
                              final ratingAvg =
                                  (data['ratingAvg'] ?? 0)
                                      .toDouble();
                              final ratingCount =
                                  data['ratingCount'] ?? 0;
                              final photoUrl =
                                  data['profilePhotoUrl'] ?? '';
                              final bio = data['bio'] ?? '';

                              return _ProviderCard(
                                providerId: providerId,
                                data: data,
                                skills: skills,
                                online: online,
                                ratingAvg: ratingAvg,
                                ratingCount: ratingCount,
                                photoUrl: photoUrl,
                                bio: bio,
                              );
                            },
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

// ── PROVIDER CARD ─────────────────────────────────────────────────────────────
class _ProviderCard extends StatelessWidget {
  final String providerId;
  final Map<String, dynamic> data;
  final String skills;
  final bool online;
  final double ratingAvg;
  final int ratingCount;
  final String photoUrl;
  final String bio;

  const _ProviderCard({
    required this.providerId,
    required this.data,
    required this.skills,
    required this.online,
    required this.ratingAvg,
    required this.ratingCount,
    required this.photoUrl,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch the real name from the users collection — this is the source of truth
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get(),
      builder: (context, userSnap) {
        final name = userSnap.hasData && userSnap.data!.exists
            ? (userSnap.data!.data() as Map<String, dynamic>)['username'] ??
                data['username'] ??
                'Provider'
            : data['username'] ?? 'Provider';

        return GestureDetector(
          // Tap anywhere on card → public profile
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProviderPublicProfileView(providerId: providerId),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar + online dot
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/images/onboard1.jpg')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: online ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(skills,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(bio,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (ratingCount > 0) ...[
                            const Icon(Icons.star,
                                size: 13, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(ratingAvg.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text(' ($ratingCount)',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ] else ...[
                            const Icon(Icons.star_border,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 2),
                            const Text('New',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: online
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              online ? 'Available' : 'Busy',
                              style: TextStyle(
                                fontSize: 10,
                                color: online ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Book button — stopPropagation via onTap override
                GestureDetector(
                  onTap: online
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingFormView(
                                providerId: providerId,
                                serviceId: 'service1',
                                subServiceKey: skills.split(',').first.trim(),
                              ),
                            ),
                          )
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: online ? Colors.black : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      online ? "Book Now" : "Busy",
                      style: TextStyle(
                        fontSize: 12,
                        color: online ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
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