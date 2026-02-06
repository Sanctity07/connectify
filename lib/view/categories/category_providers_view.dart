import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/view/bookings/booking_form_view.dart';
import 'package:flutter/material.dart';

class CategoryProvidersView extends StatelessWidget {
  final String category;

  const CategoryProvidersView({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              /// HEADER (Home style)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                        child: CircularProgressIndicator(),
                      );
                    }

                    final providers = snapshot.data!.docs.where((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;
                      final skills =
                          List<String>.from(data['skills'] ?? []);
                      return skills.any(
                        (skill) =>
                            skill.toLowerCase() ==
                            category.toLowerCase(),
                      );
                    }).toList();

                    if (providers.isEmpty) {
                      return Center(
                        child: Text(
                          'No providers available for $category',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final data = providers[index].data()
                            as Map<String, dynamic>;
                        final providerId = providers[index].id;
                        final skills = (data['skills']
                                    as List<dynamic>?)
                                ?.join(', ') ??
                            '';

                        return Container(
                          margin:
                              const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
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
                              const CircleAvatar(
                                radius: 26,
                                backgroundImage: AssetImage(
                                  'assets/images/onboard1.jpg',
                                ),
                              ),
                              const SizedBox(width: 12),

                              /// INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['username'] ??
                                          'Provider',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      skills,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// BOOK BUTTON
                              ElevatedButton(
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Book'),
                              ),
                            ],
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
