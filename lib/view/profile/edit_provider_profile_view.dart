// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProviderProfileView extends StatefulWidget {
  const EditProviderProfileView({super.key});

  @override
  State<EditProviderProfileView> createState() =>
      _EditProviderProfileViewState();
}

class _EditProviderProfileViewState extends State<EditProviderProfileView> {
  final phoneController = TextEditingController();
  final skillsController = TextEditingController();
  final bioController = TextEditingController();
  final serviceAreaController = TextEditingController();
  int yearsOfExperience = 0;
  bool online = false;
  bool loading = true;
  bool isSaving = false;
  bool isUploadingPhoto = false;
  bool isUploadingPortfolio = false;
  String photoUrl = '';
  List<String> portfolioPhotos = [];

  static const int maxPortfolioPhotos = 5;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  @override
  void dispose() {
    phoneController.dispose();
    skillsController.dispose();
    bioController.dispose();
    serviceAreaController.dispose();
    super.dispose();
  }

  Future<void> _loadProvider() async {
    final uid = AuthServices().currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('providers')
        .doc(uid)
        .get();
    if (!doc.exists) {
      setState(() => loading = false);
      return;
    }
    final data = doc.data()!;
    phoneController.text = data['phoneNumber'] ?? '';
    skillsController.text = (data['skills'] as List? ?? []).join(', ');
    bioController.text = data['bio'] ?? '';
    serviceAreaController.text = data['serviceArea'] ?? '';
    yearsOfExperience = data['yearsOfExperience'] ?? 0;
    online = data['online'] ?? false;
    photoUrl = data['profilePhotoUrl'] ?? '';
    portfolioPhotos = List<String>.from(data['portfolioPhotos'] ?? []);
    setState(() => loading = false);
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    final uid = AuthServices().currentUser!.uid;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75, maxWidth: 512);
    if (picked == null) return;
    setState(() => isUploadingPhoto = true);
    try {
      final url = await StorageService()
          .uploadProfilePhoto(uid: uid, file: File(picked.path));
      setState(() => photoUrl = url);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profilePhotoUrl': url});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
    setState(() => isUploadingPhoto = false);
  }

  Future<void> _addPortfolioPhoto() async {
    if (portfolioPhotos.length >= maxPortfolioPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maximum 5 portfolio photos")));
      return;
    }
    final uid = AuthServices().currentUser!.uid;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75, maxWidth: 800);
    if (picked == null) return;
    setState(() => isUploadingPortfolio = true);
    try {
      final url = await StorageService().uploadPortfolioPhoto(
          uid: uid, file: File(picked.path), index: portfolioPhotos.length);
      setState(() => portfolioPhotos.add(url));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
    setState(() => isUploadingPortfolio = false);
  }

  Future<void> saveChanges() async {
    final uid = AuthServices().currentUser!.uid;
    setState(() => isSaving = true);
    final skills = skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final currentUsername = userDoc.data()?['username'] ?? '';
    await FirebaseFirestore.instance
        .collection('providers')
        .doc(uid)
        .update({
      'phoneNumber': phoneController.text.trim(),
      'skills': skills,
      'bio': bioController.text.trim(),
      'serviceArea': serviceAreaController.text.trim(),
      'yearsOfExperience': yearsOfExperience,
      'online': online,
      'profilePhotoUrl': photoUrl,
      'portfolioPhotos': portfolioPhotos,
      'username': currentUsername,
    });
    setState(() => isSaving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          backgroundColor: Color(0xFFF6F5EF),
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 4),
                  const Text("Edit Profile",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist')),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── PROFILE PHOTO ─────────────────────────────────
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadProfilePhoto,
                            child: CircleAvatar(
                              radius: 52,
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
                          GestureDetector(
                            onTap: _pickAndUploadProfilePhoto,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                  color: Colors.black, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                        child: Text("Tap to change profile photo",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12))),

                    const SizedBox(height: 24),

                    // ── AVAILABILITY ──────────────────────────────────
                    _card(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: online
                              ? Colors.green.withOpacity(0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SwitchListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Available for jobs",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            online
                                ? "Visible to customers"
                                : "Hidden from customers",
                            style: TextStyle(
                                fontSize: 12,
                                color: online ? Colors.green : Colors.grey),
                          ),
                          value: online,
                          activeColor: Colors.green,
                          onChanged: (val) => setState(() => online = val),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── BASIC INFO ────────────────────────────────────
                    const _SectionLabel("Basic Info"),
                    const SizedBox(height: 10),
                    _card(
                      child: Column(
                        children: [
                          _inputField(
                              controller: phoneController,
                              hint: "Phone Number",
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 14),
                          _inputField(
                              controller: serviceAreaController,
                              hint:
                                  "Service Area (e.g. Lagos Island, Victoria Island)",
                              icon: Icons.location_on_outlined),
                          const SizedBox(height: 14),
                          // Years of experience stepper
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium_outlined,
                                  color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                  child: Text("Years of Experience",
                                      style: TextStyle(fontSize: 14))),
                              _StepperButton(
                                  onTap: () {
                                    if (yearsOfExperience > 0)
                                      setState(() => yearsOfExperience--);
                                  },
                                  icon: Icons.remove),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text('$yearsOfExperience',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _StepperButton(
                                  onTap: () =>
                                      setState(() => yearsOfExperience++),
                                  icon: Icons.add),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── SKILLS ────────────────────────────────────────
                    const _SectionLabel("Skills & Services"),
                    const SizedBox(height: 10),
                    _card(
                      child: _inputField(
                          controller: skillsController,
                          hint:
                              "e.g. Plumber, Electrician, Cleaner (comma separated)",
                          icon: Icons.build_outlined,
                          maxLines: 2),
                    ),

                    const SizedBox(height: 16),

                    // ── BIO ───────────────────────────────────────────
                    const _SectionLabel("About You"),
                    const SizedBox(height: 10),
                    _card(
                      child: _inputField(
                          controller: bioController,
                          hint:
                              "Tell customers about yourself — your experience, approach, and why they should hire you",
                          icon: Icons.info_outline,
                          maxLines: 5),
                    ),

                    const SizedBox(height: 16),

                    // ── PORTFOLIO ─────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionLabel("Portfolio Photos"),
                        Text('${portfolioPhotos.length}/$maxPortfolioPhotos',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("Show customers your past work",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...portfolioPhotos.asMap().entries.map(
                                (entry) => Stack(children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                          image: NetworkImage(entry.value),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 14,
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => portfolioPhotos.removeAt(
                                              entry.key)),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.close,
                                            size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                          if (portfolioPhotos.length < maxPortfolioPhotos)
                            GestureDetector(
                              onTap: _addPortfolioPhoto,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1.5),
                                ),
                                child: isUploadingPortfolio
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate,
                                              size: 28,
                                              color: Colors.grey.shade400),
                                          const SizedBox(height: 4),
                                          Text("Add Photo",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade400)),
                                        ],
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Save Changes",
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 5))
          ],
        ),
        child: child,
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Urbanist'));
}

class _StepperButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _StepperButton({required this.onTap, required this.icon});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration:
              BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: Colors.black),
        ),
      );
}