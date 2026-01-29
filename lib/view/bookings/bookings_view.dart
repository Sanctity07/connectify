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
      return const Scaffold(
        body: Center(child: Text("You are not logged in")),
      );
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    return FutureBuilder<DocumentSnapshot>(
      future: userRef.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData =
            snapshot.data!.data() as Map<String, dynamic>;
        final role = userData['role'] ?? 'customer';

        final isProvider =
            role == 'provider' || role == 'provider_verified';

        return Scaffold(
          appBar: AppBar(
            title: Text(isProvider ? "Job Requests" : "My Bookings"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: isProvider
                ? _providerBookings(uid)
                : _customerBookings(uid),
          ),
        );
      },
    );
  }

  /// ---------------- PROVIDER VIEW ----------------
  Widget _providerBookings(String uid) {
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
          return const Center(
            child: Text(
              "No booking requests yet",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data =
                docs[index].data() as Map<String, dynamic>;
            final bookingId = docs[index].id;
            final status = data['status'] ?? 'pending';
            final description = data['description'] ?? '';
            final customerId = data['customerId'] ?? 'Unknown';

            return _bookingCard(
              title: "Customer ID",
              value: customerId,
              description: description,
              status: status,
              actions: _providerActions(status, bookingId),
            );
          },
        );
      },
    );
  }

  /// ---------------- CUSTOMER VIEW ----------------
  Widget _customerBookings(String uid) {
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
          return const Center(
            child: Text(
              "You haven’t made any bookings yet",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data =
                docs[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final description = data['description'] ?? '';
            final providerId = data['providerId'] ?? 'Unknown';

            return _bookingCard(
              title: "Provider ID",
              value: providerId,
              description: description,
              status: status,
            );
          },
        );
      },
    );
  }


  Widget _bookingCard({
    required String title,
    required String value,
    required String description,
    required String status,
    List<Widget>? actions,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title: $value",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusChip(status),
                if (actions != null)
                  Wrap(spacing: 8, children: actions),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- STATUS CHIP ----------------
  Widget _statusChip(String status) {
    final color = switch (status) {
      'accepted' => Colors.green,
      'started' => Colors.orange,
      'completed' => Colors.blue,
      'declined' => Colors.red,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  /// ---------------- PROVIDER ACTIONS ----------------
  List<Widget> _providerActions(String status, String bookingId) {
    final vm = BookingViewModel();

    if (status == 'pending' || status == 'offered') {
      return [
        ElevatedButton(
          onPressed: () => vm.acceptJob(bookingId),
          child: const Text("Accept"),
        ),
        OutlinedButton(
          onPressed: () => vm.declineJob(bookingId),
          child: const Text("Decline"),
        ),
      ];
    }

    if (status == 'accepted') {
      return [
        ElevatedButton(
          onPressed: () => vm.startJob(bookingId),
          child: const Text("Start Job"),
        ),
      ];
    }

    if (status == 'started') {
      return [
        ElevatedButton(
          onPressed: () => vm.completeJob(bookingId),
          child: const Text("Complete"),
        ),
      ];
    }

    return [];
  }
}
