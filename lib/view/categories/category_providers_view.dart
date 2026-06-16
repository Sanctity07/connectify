// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/view/home/provider_card.dart';
import 'package:flutter/material.dart';

class CategoryProvidersView extends StatefulWidget {
  final String category;

  const CategoryProvidersView({super.key, required this.category});

  @override
  State<CategoryProvidersView> createState() => _CategoryProvidersViewState();
}

class _CategoryProvidersViewState extends State<CategoryProvidersView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.category,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search ${widget.category} providers...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Single-field query only — arrayContains alone needs no composite index.
                // Filter status client-side to avoid requiring an index.
                stream: FirebaseFirestore.instance
                    .collection('providers')
                    .where('skills', arrayContains: widget.category)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading providers.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  // Filter verified + search client-side
                  var providers = (snapshot.data?.docs ?? []).where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return (data['status'] ?? '') == 'verified';
                  }).toList();

                  if (_searchQuery.isNotEmpty) {
                    providers = providers.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['username'] ?? '').toString().toLowerCase();
                      final bio =
                          (data['bio'] ?? '').toString().toLowerCase();
                      final skills = List<String>.from(data['skills'] ?? [])
                          .join(' ')
                          .toLowerCase();
                      return name.contains(_searchQuery) ||
                          bio.contains(_searchQuery) ||
                          skills.contains(_searchQuery);
                    }).toList();
                  }

                  if (providers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 52, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No results for "$_searchQuery"'
                                : 'No providers for ${widget.category}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data =
                          providers[index].data() as Map<String, dynamic>;
                      final providerId = providers[index].id;
                      final skills = (data['skills'] as List<dynamic>?)
                              ?.join(', ') ??
                          '';

                      return ProviderCard(
                        providerId: providerId,
                        data: data,
                        skills: skills,
                        online: data['online'] ?? false,
                        ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
                        ratingCount: data['ratingCount'] ?? 0,
                        photoUrl: data['profilePhotoUrl'] ?? '',
                        bio: data['bio'] ?? '',
                        overrideSubServiceKey: widget.category,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
