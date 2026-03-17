// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/viewmodels/booking_viewmodel.dart';
import 'package:connectify/widgets/rating_bottom_sheet.dart';
import 'package:flutter/material.dart';

class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthServices().currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final role = userData['role'] ?? 'customer';
        final isProvider =
            role == 'provider' || role == 'provider_verified';

        return DefaultTabController(
          length: isProvider ? 2 : 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF6F5EF),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      isProvider ? "Job Requests" : "My Bookings",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        tabs: isProvider
                            ? const [
                                Tab(text: "Active"),
                                Tab(text: "History"),
                              ]
                            : const [
                                Tab(text: "Active"),
                                Tab(text: "History"),
                              ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: TabBarView(
                      children: isProvider
                          ? [
                              _ProviderBookingsList(
                                  uid: uid, historyMode: false),
                              _ProviderBookingsList(
                                  uid: uid, historyMode: true),
                            ]
                          : [
                              _CustomerBookingsList(
                                  uid: uid, historyMode: false),
                              _CustomerBookingsList(
                                  uid: uid, historyMode: true),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── PROVIDER BOOKINGS LIST ───────────────────────────────────────────────────
class _ProviderBookingsList extends StatelessWidget {
  final String uid;
  final bool historyMode;

  const _ProviderBookingsList(
      {required this.uid, required this.historyMode});

  @override
  Widget build(BuildContext context) {
    final activeStatuses = ['pending', 'offered', 'accepted', 'started'];
    final historyStatuses = ['completed', 'declined', 'cancelled'];

    Query query = FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final status =
              (doc.data() as Map<String, dynamic>)['status'] ?? '';
          return historyMode
              ? historyStatuses.contains(status)
              : activeStatuses.contains(status);
        }).toList();

        if (docs.isEmpty) {
          return _emptyState(
              historyMode ? "No past jobs" : "No active requests");
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final bookingId = docs[index].id;
            final status = data['status'] ?? 'pending';
            final customerId = data['customerId'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(customerId)
                  .get(),
              builder: (context, userSnap) {
                final customerName = userSnap.hasData &&
                        userSnap.data!.exists
                    ? (userSnap.data!.data()
                            as Map<String, dynamic>)['username'] ??
                        'Customer'
                    : 'Customer';
                final customerPhoto = userSnap.hasData &&
                        userSnap.data!.exists
                    ? (userSnap.data!.data()
                            as Map<String, dynamic>)['profilePhotoUrl'] ??
                        ''
                    : '';

                return _BookingCard(
                  bookingId: bookingId,
                  data: data,
                  status: status,
                  personName: customerName,
                  personPhoto: customerPhoto,
                  personLabel: "Customer",
                  isProvider: true,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── CUSTOMER BOOKINGS LIST ───────────────────────────────────────────────────
class _CustomerBookingsList extends StatelessWidget {
  final String uid;
  final bool historyMode;

  const _CustomerBookingsList(
      {required this.uid, required this.historyMode});

  @override
  Widget build(BuildContext context) {
    final activeStatuses = ['pending', 'offered', 'accepted', 'started'];
    final historyStatuses = ['completed', 'declined', 'cancelled'];

    Query query = FirebaseFirestore.instance
        .collection('bookings')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final status =
              (doc.data() as Map<String, dynamic>)['status'] ?? '';
          return historyMode
              ? historyStatuses.contains(status)
              : activeStatuses.contains(status);
        }).toList();

        if (docs.isEmpty) {
          return _emptyState(historyMode
              ? "No booking history"
              : "No active bookings");
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final bookingId = docs[index].id;
            final status = data['status'] ?? 'pending';
            final providerId = data['providerId'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('providers')
                  .doc(providerId)
                  .get(),
              builder: (context, provSnap) {
                // get name from users collection using providerId
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(providerId)
                      .get(),
                  builder: (context, userSnap) {
                    final providerName = userSnap.hasData &&
                            userSnap.data!.exists
                        ? (userSnap.data!.data()
                                as Map<String, dynamic>)['username'] ??
                            'Provider'
                        : 'Provider';
                    final providerPhoto = userSnap.hasData &&
                            userSnap.data!.exists
                        ? (userSnap.data!.data()
                                as Map<String, dynamic>)[
                                'profilePhotoUrl'] ??
                            ''
                        : '';
                    final ratingAvg = provSnap.hasData &&
                            provSnap.data!.exists
                        ? ((provSnap.data!.data() as Map<String,
                                    dynamic>)['ratingAvg'] ??
                                0)
                            .toDouble()
                        : 0.0;

                    return _BookingCard(
                      bookingId: bookingId,
                      data: data,
                      status: status,
                      personName: providerName,
                      personPhoto: providerPhoto,
                      personLabel: "Provider",
                      isProvider: false,
                      providerRating: ratingAvg,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── BOOKING CARD ─────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> data;
  final String status;
  final String personName;
  final String personPhoto;
  final String personLabel;
  final bool isProvider;
  final double providerRating;

  const _BookingCard({
    required this.bookingId,
    required this.data,
    required this.status,
    required this.personName,
    required this.personPhoto,
    required this.personLabel,
    required this.isProvider,
    this.providerRating = 0,
  });

  @override
  Widget build(BuildContext context) {
    final service = data['subServiceKey'] ?? 'Service';
    final address = data['address'] ?? '';
    final description = data['description'] ?? '';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final dateStr = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Person row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: personPhoto.isNotEmpty
                    ? NetworkImage(personPhoto)
                    : const AssetImage('assets/images/onboard1.jpg')
                        as ImageProvider,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      personLabel,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Service + details
          Row(
            children: [
              const Icon(Icons.build_outlined,
                  size: 14, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(service,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),

          if (address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(address,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],

          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],

          if (!isProvider && providerRating > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 13, color: Colors.amber),
                const SizedBox(width: 4),
                Text(providerRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],

          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(dateStr,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11)),
          ],

          // Action buttons
          const SizedBox(height: 12),
          _ActionButtons(
            bookingId: bookingId,
            status: status,
            isProvider: isProvider,
            providerId: data['providerId'] ?? '',
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final (color, bg) = switch (status) {
      'accepted' => (Colors.green, Colors.green.withOpacity(0.12)),
      'started' => (Colors.orange, Colors.orange.withOpacity(0.12)),
      'completed' => (Colors.blue, Colors.blue.withOpacity(0.12)),
      'declined' => (Colors.red, Colors.red.withOpacity(0.12)),
      'cancelled' => (Colors.red, Colors.red.withOpacity(0.12)),
      _ => (Colors.grey, Colors.grey.withOpacity(0.12)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── ACTION BUTTONS ────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final String bookingId;
  final String status;
  final bool isProvider;
  final String providerId;

  const _ActionButtons({
    required this.bookingId,
    required this.status,
    required this.isProvider,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final vm = BookingViewModel();

    if (isProvider) {
      if (status == 'pending' || status == 'offered') {
        return Row(
          children: [
            _btn("Accept", Colors.black,
                () => vm.acceptJob(bookingId)),
            const SizedBox(width: 8),
            _outlineBtn("Decline", () => vm.declineJob(bookingId)),
          ],
        );
      }
      if (status == 'accepted') {
        return _btn(
            "Start Job", Colors.black, () => vm.startJob(bookingId));
      }
      if (status == 'started') {
        return _btn("Mark Complete", Colors.deepPurple,
            () => vm.completeJob(bookingId));
      }
    } else {
      // Customer actions
      if (status == 'pending') {
        return _outlineBtn(
          "Cancel Booking",
          () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text("Cancel Booking"),
                content: const Text(
                    "Are you sure you want to cancel this booking?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Yes, Cancel"),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await vm.cancelJob(bookingId);
            }
          },
          color: Colors.red,
        );
      }

      if (status == 'completed') {
        // Check if already rated
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('ratings')
              .where('bookingId', isEqualTo: bookingId)
              .limit(1)
              .get(),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox();
            if (snap.data!.docs.isNotEmpty) {
              // Already rated
              return Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    "Rated ${(snap.data!.docs.first.data() as Map)['stars']}★",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              );
            }
            return _btn(
              "Rate Provider",
              Colors.amber.shade700,
              () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => RatingBottomSheet(
                  bookingId: bookingId,
                  providerId: providerId,
                ),
              ),
            );
          },
        );
      }
    }

    return const SizedBox();
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _outlineBtn(String label, VoidCallback onTap,
      {Color color = Colors.black}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

//HELPERS
Widget _emptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 52, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );
}