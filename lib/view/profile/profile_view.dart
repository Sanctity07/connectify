// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/services/storage_service.dart';
import 'package:connectify/view/profile/booking_history_tab.dart';
import 'package:connectify/view/profile/provider_profile_tab.dart';
import 'package:connectify/view/profile/settings_view.dart';
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> get _userStream =>
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> get _providerStream =>
      FirebaseFirestore.instance
          .collection('providers')
          .doc(uid)
          .snapshots();

  // ── PHOTO UPLOAD 
  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75, maxWidth: 512);
    if (picked == null) return;

    setState(() => isUploadingPhoto = true);
    try {
      final url = await StorageService()
          .uploadProfilePhoto(uid: uid, file: File(picked.path));
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profilePhotoUrl': url});
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(uid)
          .update({'profilePhotoUrl': url}).catchError((_) {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Photo upload failed: $e')));
    }
    setState(() => isUploadingPhoto = false);
  }

  // ── EDIT DISPLAY NAME 
  Future<void> _editDisplayName(String currentName) async {
    usernameController.text = currentName;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: 'Your name',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              final name = usernameController.text.trim();
              if (name.isEmpty) return;
              final nav = Navigator.of(context);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({'username': name});
              nav.pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── BECOME PROVIDER FORM 
  Future<void> _submitProviderForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    // status = 'pending' — admin must approve via the admin website
    // before the user becomes a verified provider.
    // role stays 'customer' until approval.
    await FirebaseFirestore.instance.collection('providers').doc(uid).set({
      'userId': uid,
      'phoneNumber': phoneController.text.trim(),
      'skills':
          skillsController.text.split(',').map((e) => e.trim()).toList(),
      'status': 'pending',
      'online': false,
      'ratingAvg': 0,
      'ratingCount': 0,
      'balance': 0,
      'pendingPayout': 0,
      'profilePhotoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Do NOT update role to 'provider' here.
    // The admin website sets status → 'verified' and role → 'provider'
    // once they approve the request.

    setState(() => isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request submitted! You\'ll be notified once approved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
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
        final email = userData['email'] ?? '';
        final photoUrl = userData['profilePhotoUrl'] ?? '';
        final isProvider =
            role == 'provider' || role == 'provider_verified';

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _providerStream,
          builder: (context, providerSnap) {
            final providerData = providerSnap.data?.data();
            final status = (providerData?['status'] ?? 'none')
                .toString()
                .toLowerCase();

            return Scaffold(
              backgroundColor: const Color(0xFFF6F5EF),
              body: SafeArea(
                child: Column(
                  children: [
                    // ── HEADER 
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          // Settings button → navigates to SettingsView
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SettingsView(
                                  uid: uid,
                                  email: email,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                  Icons.settings_outlined,
                                  size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── AVATAR 
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
                              shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              size: 14, color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── NAME + EMAIL 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
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
                      email,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),

                    // ── ROLE BADGE 
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
                          color: isProvider
                              ? Colors.deepPurple
                              : Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── TABS 
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.deepPurple,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.deepPurple,
                      tabs: isProvider
                          ? const [
                              Tab(text: 'My Profile'),
                              Tab(text: 'Bookings'),
                            ]
                          : [
                              Tab(
                                text: status == 'pending'
                                    ? 'Application ⏳'
                                    : status == 'rejected'
                                        ? 'Resubmit'
                                        : 'Become a Provider',
                              ),
                              const Tab(text: 'My Bookings'),
                            ],
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: isProvider
                            ? [
                                ProviderProfileTab(
                                    providerData: providerData),
                                BookingHistoryTab(
                                    uid: uid, isProvider: true),
                              ]
                            : [
                                _BecomeProviderTab(
                                  formKey: _formKey,
                                  phoneController: phoneController,
                                  skillsController: skillsController,
                                  isLoading: isLoading,
                                  status: status,
                                  onSubmit: _submitProviderForm,
                                ),
                                BookingHistoryTab(
                                    uid: uid, isProvider: false),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── BECOME PROVIDER TAB (kept here as it's small and profile-specific) ────────
class _BecomeProviderTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController skillsController;
  final bool isLoading;
  final String status;
  final VoidCallback onSubmit;

  const _BecomeProviderTab({
    required this.formKey,
    required this.phoneController,
    required this.skillsController,
    required this.isLoading,
    required this.status,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // ── PENDING ──────────────────────────────────────────────────────────────
    if (status == 'pending') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    size: 36, color: Colors.orange),
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Under Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your provider application has been submitted and is being reviewed by our team. We\'ll notify you once it\'s approved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.orange),
                    SizedBox(width: 6),
                    Text(
                      'Usually takes 24–48 hours',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── REJECTED ─────────────────────────────────────────────────────────────
    if (status == 'rejected') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    size: 36, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text(
                'Application Not Approved',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your provider request was not approved at this time. You may update your details and resubmit.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 24),
              _buildForm(context),
            ],
          ),
        ),
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
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
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start offering your services',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist'),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in your details to become a provider on Connectify.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _Field(
                  controller: phoneController,
                  hint: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _Field(
                  controller: skillsController,
                  hint: 'Skills (e.g. Plumber, Electrician)',
                  icon: Icons.build,
                  maxLines: 2),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Application',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FORM FIELD HELPER 
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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