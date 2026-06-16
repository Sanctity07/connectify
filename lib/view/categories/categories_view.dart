// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'category_providers_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  String searchQuery = '';

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Cleaner',
      'icon': Icons.cleaning_services,
      'color': Color(0xFF4FC3F7),
    },
    {
      'name': 'IT Solutions',
      'icon': Icons.computer,
      'color': Color(0xFF7986CB),
    },
    {
      'name': 'Plumber',
      'icon': Icons.plumbing,
      'color': Color(0xFF4DB6AC),
    },
    {
      'name': 'Electrician',
      'icon': Icons.electrical_services,
      'color': Color(0xFFFFB74D),
    },
    {
      'name': 'Carpenter',
      'icon': Icons.build,
      'color': Color(0xFF8D6E63),
    },
    {
      'name': 'Painter',
      'icon': Icons.brush,
      'color': Color(0xFFBA68C8),
    },
    {
      'name': 'Gardening',
      'icon': Icons.grass,
      'color': Color(0xFF81C784),
    },
    {
      'name': 'Tutoring',
      'icon': Icons.school,
      'color': Color(0xFFFF8A65),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _categories
        .where((c) =>
            (c['name'] as String)
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Browse all service categories',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 20),

              // Search bar
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
                    const Icon(Icons.search_rounded, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => searchQuery = v),
                        decoration: const InputDecoration(
                          hintText: 'Search categories...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              'No categories found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        itemCount: filtered.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.05,
                        ),
                        itemBuilder: (context, index) {
                          final cat = filtered[index];
                          return _CategoryCard(category: cat);
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

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final name = category['name'] as String;
    final icon = category['icon'] as IconData;
    final color = category['color'] as Color;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryProvidersView(category: name),
        ),
      ),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Live provider count — single-field query, no composite index needed
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('providers')
                  .where('skills', arrayContains: name)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 14);
                }
                if (snap.hasError || !snap.hasData) {
                  return const SizedBox(height: 14);
                }
                // Filter verified client-side to avoid composite index
                final count = snap.data!.docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return (d['status'] ?? '') == 'verified';
                }).length;
                return Text(
                  count == 0
                      ? 'No providers'
                      : '$count provider${count == 1 ? '' : 's'}',
                  style: TextStyle(color: color, fontSize: 11),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
