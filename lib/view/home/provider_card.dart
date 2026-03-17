// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/view/bookings/booking_form_view.dart';
import 'package:connectify/view/provider/provider_public_profile_view.dart';
import 'package:flutter/material.dart';

class ProviderCard extends StatelessWidget {
  final String providerId;
  final Map<String, dynamic> data;
  final String skills;
  final bool online;
  final double ratingAvg;
  final int ratingCount;
  final String photoUrl;
  final String bio;

  const ProviderCard({
    super.key,
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
          // Whole card → public profile
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
                // ── AVATAR + ONLINE DOT ───────────────────────────
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
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // ── INFO ──────────────────────────────────────────
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
                      Text(
                        skills,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          bio,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (ratingCount > 0) ...[
                            const Icon(Icons.star,
                                size: 13, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              ratingAvg.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              ' ($ratingCount)',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ] else ...[
                            const Icon(Icons.star_border,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 2),
                            const Text(
                              'New',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
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
                                color: online
                                    ? Colors.green
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── BOOK BUTTON (tap doesn't bubble to card) ──────
                GestureDetector(
                  onTap: online
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingFormView(
                                providerId: providerId,
                                serviceId: 'service1',
                                subServiceKey:
                                    skills.split(',').first.trim(),
                              ),
                            ),
                          )
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: online
                          ? Colors.black
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      online ? 'Book Now' : 'Busy',
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