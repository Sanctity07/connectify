import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/viewmodels/booking_viewmodel.dart';
import 'package:flutter/material.dart';

class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthServices().currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("Not logged in"));
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    return FutureBuilder<DocumentSnapshot>(
      future: userRef.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final role = userData['role'] ?? 'customer';

        //  PROVIDER VIEW 
        if (role == 'provider_verified' || role == 'provider') {
          final bookingsQuery = FirebaseFirestore.instance
              .collection('bookings')
              .where('providerId', isEqualTo: uid)
              .orderBy('createdAt', descending: true);

          return StreamBuilder<QuerySnapshot>(
            stream: bookingsQuery.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text("No booking requests"));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final bookingId = docs[index].id;
                  final status = data['status'] ?? 'pending';
                  final customerId = data['customerId'] ?? 'Unknown';
                  final description = data['description'] ?? '';

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("Booking from: $customerId"),
                      subtitle: Text("Status: $status\n$description"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status == 'pending' || status == 'offered') ...[
                            ElevatedButton(
                              onPressed: () async {
                                await BookingViewModel().acceptJob(bookingId);
                              },
                              child: const Text("Accept"),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: () async {
                                await BookingViewModel().declineJob(bookingId);
                              },
                              child: const Text("Decline"),
                            ),
                          ],
                          if (status == 'accepted') ...[
                            ElevatedButton(
                              onPressed: () async {
                                await BookingViewModel().startJob(bookingId);
                              },
                              child: const Text("Start"),
                            ),
                          ],
                          if (status == 'started') ...[
                            ElevatedButton(
                              onPressed: () async {
                                await BookingViewModel().completeJob(bookingId);
                              },
                              child: const Text("Complete"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        else {
          final bookingsQuery = FirebaseFirestore.instance
              .collection('bookings')
              .where('customerId', isEqualTo: uid)
              .orderBy('createdAt', descending: true);

          return StreamBuilder<QuerySnapshot>(
            stream: bookingsQuery.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text("No bookings made"));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  final providerId = data['providerId'] ?? 'Unknown';
                  final description = data['description'] ?? '';

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("Provider: $providerId"),
                      subtitle: Text(
                        "Status: $status\n$description",
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
