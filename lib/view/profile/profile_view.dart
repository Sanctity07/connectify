// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/services/storage_service.dart';
import 'package:connectify/view/auth/login_view.dart';
import 'package:connectify/view/profile/edit_provider_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final skillsController = TextEditingController();
  final usernameController = TextEditingController();
  bool isLoading = false;
  bool isUploadingPhoto = false;
  late TabController _tabController;

  String get uid => AuthServices().currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() =>
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> providerStream() =>
      FirebaseFirestore.instance.collection('providers').doc(uid).snapshots();

  Future<void> logout() async {
    await AuthServices().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  Future<void> submitProviderForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection('providers').doc(uid).set({
      'userId': uid,
      'phoneNumber': phoneController.text.trim(),
      'skills':
          skillsController.text.split(',').map((e) => e.trim()).toList(),
      'status': 'verified', // auto-verify for MVP
      'online': true,
      'ratingAvg': 0,
      'ratingCount': 0,
      'balance': 0,
      'pendingPayout': 0,
      'profilePhotoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': 'provider',
    });

    setState(() => isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You are now a provider!")),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 512,
    );
    if (picked == null) return;

    setState(() => isUploadingPhoto = true);
    try {
      final url = await StorageService().uploadProfilePhoto(
        uid: uid,
        file: File(picked.path),
      );
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePhotoUrl': url,
      });
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(uid)
          .update({'profilePhotoUrl': url}).catchError((_) {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo upload failed: $e")),
      );
    }
    setState(() => isUploadingPhoto = false);
  }

  Future<void> _editDisplayName(String currentName) async {
    usernameController.text = currentName;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Display Name"),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: "Your name",
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              final name = usernameController.text.trim();
              if (name.isEmpty) return;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({'username': name});
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userStream(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F5EF),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnap.data!.data()!;
        final role =
            (userData['role'] ?? 'customer').toString().toLowerCase();
        final username = userData['username'] ?? 'User';
        final photoUrl = userData['profilePhotoUrl'] ?? '';

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: providerStream(),
          builder: (context, providerSnap) {
            final providerData = providerSnap.data?.data();
            final status =
                (providerData?['status'] ?? 'none').toString().toLowerCase();
            final isProvider =
                role == 'provider' || role == 'provider_verified';

            return Scaffold(
              backgroundColor: const Color(0xFFF6F5EF),
              body: SafeArea(
                child: Column(
                  children: [
                    // ── TOP HEADER ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          TextButton.icon(
                            onPressed: logout,
                            icon: const Icon(Icons.logout,
                                size: 18, color: Colors.red),
                            label: const Text("Logout",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),

                    // ── AVATAR + NAME ────────────────────────────────────
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadPhoto,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : const AssetImage(
                                        'assets/images/onboard1.jpg')
                                    as ImageProvider,
                            child: isUploadingPhoto
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 14, color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Name + edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _editDisplayName(username),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.grey),
                        ),
                      ],
                    ),

                    Text(
                      userData['email'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    // Role badge
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isProvider
                            ? Colors.deepPurple.withOpacity(0.12)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isProvider ? '⚡ Provider' : '👤 Customer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isProvider ? Colors.deepPurple : Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── TABS (only for provider) ─────────────────────────
                    if (isProvider) ...[
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.deepPurple,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.deepPurple,
                        tabs: const [
                          Tab(text: 'My Profile'),
                          Tab(text: 'Bookings'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _providerProfileTab(providerData),
                            _bookingHistoryTab(uid, isProvider: true),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Customer: tabs for Become Provider + Booking History
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.deepPurple,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.deepPurple,
                        tabs: const [
                          Tab(text: 'Become a Provider'),
                          Tab(text: 'My Bookings'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _becomeProviderTab(status),
                            _bookingHistoryTab(uid, isProvider: false),
                          ],
                        ),
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

  // ── PROVIDER PROFILE TAB ────────────────────────────────────────────────
  Widget _providerProfileTab(Map<String, dynamic>? providerData) {
    if (providerData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final skills =
        (providerData['skills'] as List<dynamic>?)?.join(', ') ?? '';
    final phone = providerData['phoneNumber'] ?? 'Not set';
    final online = providerData['online'] ?? false;
    final ratingAvg = (providerData['ratingAvg'] ?? 0).toDouble();
    final ratingCount = providerData['ratingCount'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              _statCard('Rating',
                  ratingCount == 0 ? 'New' : '${ratingAvg.toStringAsFixed(1)}★',
                  Colors.amber),
              const SizedBox(width: 12),
              _statCard('Reviews', '$ratingCount', Colors.deepPurple),
              const SizedBox(width: 12),
              _statCard(
                  'Status', online ? 'Online' : 'Offline',
                  online ? Colors.green : Colors.grey),
            ],
          ),

          const SizedBox(height: 16),

          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _infoRow(Icons.phone, 'Phone', phone),
                const Divider(height: 24),
                _infoRow(Icons.build, 'Skills', skills),
                const Divider(height: 24),
                _infoRow(
                  online ? Icons.circle : Icons.circle_outlined,
                  'Availability',
                  online ? 'Available for jobs' : 'Not accepting jobs',
                  iconColor: online ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProviderProfileView()),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BECOME PROVIDER TAB ─────────────────────────────────────────────────
  Widget _becomeProviderTab(String status) {
    if (status == 'pending') {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '⏳ Your provider request is under review.\nWe will notify you once approved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Start offering your services",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Fill in your details to become a provider on Connectify.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _inputField(
                controller: phoneController,
                hint: "Phone Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _inputField(
                controller: skillsController,
                hint: "Skills (e.g. Plumber, Electrician)",
                icon: Icons.build,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitProviderForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BOOKING HISTORY TAB ─────────────────────────────────────────────────
  Widget _bookingHistoryTab(String uid, {required bool isProvider}) {
    final query = FirebaseFirestore.instance
        .collection('bookings')
        .where(isProvider ? 'providerId' : 'customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text("No bookings yet",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final service = data['subServiceKey'] ?? 'Service';
            final address = data['address'] ?? '';
            final createdAt =
                (data['createdAt'] as Timestamp?)?.toDate();
            final dateStr = createdAt != null
                ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                : '';

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.build_circle_outlined,
                        color: Colors.deepPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        if (address.isNotEmpty)
                          Text(address,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        if (dateStr.isNotEmpty)
                          Text(dateStr,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  _statusChip(status),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────
  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'accepted' => Colors.green,
      'started' => Colors.orange,
      'completed' => Colors.blue,
      'declined' => Colors.red,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}