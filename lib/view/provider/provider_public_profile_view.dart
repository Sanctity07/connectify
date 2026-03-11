// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/view/bookings/booking_form_view.dart';
import 'package:flutter/material.dart';

class ProviderPublicProfileView extends StatelessWidget {
  final String providerId;

  const ProviderPublicProfileView({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .snapshots(),
      builder: (context, provSnap) {
        if (!provSnap.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F5EF),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pData = provSnap.data!.data() as Map<String, dynamic>? ?? {};

        // Also fetch username from users collection
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(providerId)
              .get(),
          builder: (context, userSnap) {
            final uData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
            final name = uData['username'] ??
                pData['username'] ??
                'Provider';

            final photoUrl = pData['profilePhotoUrl'] ?? '';
            final bio = pData['bio'] ?? '';
            final skills = List<String>.from(pData['skills'] ?? []);
            final ratingAvg = (pData['ratingAvg'] ?? 0).toDouble();
            final ratingCount = pData['ratingCount'] ?? 0;
            final completedJobs = pData['completedJobs'] ?? 0;
            final yearsExp = pData['yearsOfExperience'] ?? 0;
            final serviceArea = pData['serviceArea'] ?? '';
            final online = pData['online'] ?? false;
            final portfolioPhotos =
                List<String>.from(pData['portfolioPhotos'] ?? []);
            final phone = pData['phoneNumber'] ?? '';

            return Scaffold(
              backgroundColor: const Color(0xFFF6F5EF),
              body: Stack(
                children: [
                  // ── SCROLLABLE CONTENT ───────────────────────────────
                  CustomScrollView(
                    slivers: [
                      // ── SLIVER HEADER ────────────────────────────────
                      SliverAppBar(
                        expandedHeight: 260,
                        pinned: true,
                        backgroundColor: Colors.white,
                        leading: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.black),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background — blurred photo or gradient
                              photoUrl.isNotEmpty
                                  ? Image.network(photoUrl,
                                      fit: BoxFit.cover)
                                  : Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF2E3A59),
                                            Color(0xFF5B4FCF),
                                          ],
                                        ),
                                      ),
                                    ),
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              // Name + availability
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Colors.white,
                                      backgroundImage: photoUrl.isNotEmpty
                                          ? NetworkImage(photoUrl)
                                          : const AssetImage(
                                                  'assets/images/onboard1.jpg')
                                              as ImageProvider,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Urbanist',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: online
                                                      ? Colors.greenAccent
                                                      : Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                online
                                                    ? 'Available now'
                                                    : 'Currently unavailable',
                                                style: TextStyle(
                                                  color: online
                                                      ? Colors.greenAccent
                                                      : Colors.grey.shade400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── BODY CONTENT ─────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── STATS ROW ──────────────────────────
                              Row(
                                children: [
                                  _StatBox(
                                    value: ratingCount == 0
                                        ? 'New'
                                        : ratingAvg.toStringAsFixed(1),
                                    label: 'Rating',
                                    icon: Icons.star,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatBox(
                                    value: '$completedJobs',
                                    label: 'Jobs Done',
                                    icon: Icons.check_circle_outline,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatBox(
                                    value: yearsExp == 0
                                        ? 'New'
                                        : '${yearsExp}yr${yearsExp > 1 ? 's' : ''}',
                                    label: 'Experience',
                                    icon: Icons.workspace_premium_outlined,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatBox(
                                    value: '$ratingCount',
                                    label: 'Reviews',
                                    icon: Icons.rate_review_outlined,
                                    color: Colors.orange,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // ── ABOUT ──────────────────────────────
                              if (bio.isNotEmpty) ...[
                                _SectionTitle('About'),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    bio,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Color(0xFF444444)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // ── DETAILS ROW ─────────────────────────
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    if (phone.isNotEmpty)
                                      _DetailRow(
                                          icon: Icons.phone_outlined,
                                          label: 'Phone',
                                          value: phone),
                                    if (phone.isNotEmpty &&
                                        serviceArea.isNotEmpty)
                                      const Divider(height: 20),
                                    if (serviceArea.isNotEmpty)
                                      _DetailRow(
                                          icon: Icons.location_on_outlined,
                                          label: 'Service Area',
                                          value: serviceArea),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ── SKILLS ─────────────────────────────
                              _SectionTitle('Services Offered'),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: skills
                                    .map((s) => Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.deepPurple
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child: Text(
                                            s,
                                            style: const TextStyle(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),

                              const SizedBox(height: 20),

                              // ── PORTFOLIO ──────────────────────────
                              if (portfolioPhotos.isNotEmpty) ...[
                                _SectionTitle('Portfolio'),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 160,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: portfolioPhotos.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, i) =>
                                        GestureDetector(
                                      onTap: () =>
                                          _showPhotoFullscreen(
                                              context,
                                              portfolioPhotos[i]),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        child: Image.network(
                                          portfolioPhotos[i],
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // ── REVIEWS ────────────────────────────
                              _SectionTitle(
                                  'Reviews${ratingCount > 0 ? ' ($ratingCount)' : ''}'),
                              const SizedBox(height: 10),

                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('ratings')
                                    .where('providerId',
                                        isEqualTo: providerId)
                                    .orderBy('createdAt',
                                        descending: true)
                                    .limit(10)
                                    .snapshots(),
                                builder: (context, ratingsSnap) {
                                  if (!ratingsSnap.hasData) {
                                    return const Center(
                                        child:
                                            CircularProgressIndicator());
                                  }

                                  final reviews =
                                      ratingsSnap.data!.docs;

                                  if (reviews.isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Text(
                                        'No reviews yet. Be the first to book!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: reviews
                                        .map((doc) => _ReviewCard(
                                            data: doc.data()
                                                as Map<String,
                                                    dynamic>))
                                        .toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── STICKY BOOK BUTTON ───────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: online
                              ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingFormView(
                                        providerId: providerId,
                                        serviceId: 'service1',
                                        subServiceKey: skills.isNotEmpty
                                            ? skills.first
                                            : 'Service',
                                      ),
                                    ),
                                  )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            online ? 'Book $name' : 'Currently Unavailable',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPhotoFullscreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                child: Image.network(url),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── REVIEW CARD ───────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ReviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final stars = data['stars'] ?? 0;
    final review = data['review'] ?? '';
    final customerId = data['customerId'] ?? '';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final dateStr = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Fetch customer name
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(customerId)
                    .get(),
                builder: (context, snap) {
                  final name = snap.hasData && snap.data!.exists
                      ? (snap.data!.data()
                              as Map<String, dynamic>)['username'] ??
                          'Customer'
                      : 'Customer';
                  final photo = snap.hasData && snap.data!.exists
                      ? (snap.data!.data()
                              as Map<String, dynamic>)[
                              'profilePhotoUrl'] ??
                          ''
                      : '';

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: photo.isNotEmpty
                            ? NetworkImage(photo)
                            : const AssetImage(
                                    'assets/images/onboard1.jpg')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          if (review.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5),
            ),
          ],
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              dateStr,
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

// ── SMALL REUSABLE WIDGETS ────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        fontFamily: 'Urbanist',
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
}