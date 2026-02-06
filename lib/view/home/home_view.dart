// ignore_for_file: deprecated_member_use
import 'package:connectify/view/bookings/booking_form_view.dart';
import 'package:connectify/view/profile/profile_view.dart';
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
  ];

  int activeIndex = 0;
  String? username;
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
          .collection("users")
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          username = data['username'] ?? user.displayName ?? "Guest";
        });
      } else {
        setState(() {
          username = user.displayName ?? "Guest";
        });
      }
    } else {
      setState(() {
        username = "Guest";
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
                  children: [
                    const SizedBox(height: 12),

                    /// PROFILE ROW
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileView(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
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
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundImage:
                                      AssetImage('assets/images/onboard1.jpg'),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      username!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.location_on_outlined),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.shopping_bag_outlined),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// TITLES
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Smart Home',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Smooth Services',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// SEARCH BAR
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                              onChanged: (value) {
                                setState(() {
                                  searchQuery =
                                      value.toLowerCase().trim();
                                });
                              },
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

                    /// CATEGORY SELECTOR
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
                            onTap: () {
                              setState(() {
                                activeIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    isActive ? Colors.black : Colors.white,
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

                    /// PROVIDERS LIST
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
                            final skills =
                                List<String>.from(data['skills'] ?? []);

                            final matchesCategory = activeIndex == 0
                                ? true
                                : skills.any((skill) =>
                                    skill.toLowerCase() ==
                                    categories[activeIndex]
                                        .toLowerCase());

                            final matchesSearch = searchQuery.isEmpty
                                ? true
                                : skills.any((skill) =>
                                    skill
                                        .toLowerCase()
                                        .contains(searchQuery));

                            return matchesCategory && matchesSearch;
                          }).toList();

                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(
                                searchQuery.isNotEmpty
                                    ? 'No providers found for "$searchQuery"'
                                    : activeIndex == 0
                                        ? 'No providers available'
                                        : 'No providers for ${categories[activeIndex]}',
                                style:
                                    const TextStyle(fontSize: 16),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final data = filtered[index].data()
                                  as Map<String, dynamic>;
                              final providerId =
                                  filtered[index].id;
                              final skills = (data['skills']
                                          as List<dynamic>?)
                                      ?.join(', ') ??
                                  '';

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/onboard1.jpg'),
                                  ),
                                  title: Text(
                                    data['username'] ?? 'Provider',
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                  subtitle: Text(skills),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BookingFormView(
                                            providerId: providerId,
                                            serviceId: 'service1',
                                            subServiceKey: skills
                                                .split(',')
                                                .first
                                                .trim(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Book Now"),
                                  ),
                                ),
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
