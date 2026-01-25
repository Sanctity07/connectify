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
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('providers')
            .where('status', isEqualTo: 'verified')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final providers = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final skills = List<String>.from(data['skills'] ?? []);
            return skills.any(
              (skill) =>
                  skill.toLowerCase() == category.toLowerCase(),
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
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final data =
                  providers[index].data() as Map<String, dynamic>;
              final providerId = providers[index].id;
              final skills =
                  (data['skills'] as List<dynamic>?)?.join(', ') ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/onboard1.jpg'),
                  ),
                  title: Text(
                    data['username'] ?? 'Provider',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(skills),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormView(
                            providerId: providerId,
                            serviceId: 'service1',
                            subServiceKey:
                                skills.split(',').first.trim(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Book Now'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
