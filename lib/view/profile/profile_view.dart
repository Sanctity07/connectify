import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/view/auth/login_view.dart';
import 'package:connectify/view/profile/edit_provider_profile_view.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final skillsController = TextEditingController();
  bool isLoading = false;

  String get uid => AuthServices().currentUser!.uid;

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> providerStream() {
    return FirebaseFirestore.instance
        .collection('providers')
        .doc(uid)
        .snapshots();
  }

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
      'skills': skillsController.text.split(',').map((e) => e.trim()).toList(),
      'status': 'pending',
      'online': false,
      'ratingAvg': 0,
      'ratingCount': 0,
      'balance': 0,
      'pendingPayout': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': 'provider_pending',
    });

    setState(() => isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Provider request submitted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userStream(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                backgroundColor: Color(0xFFF6F5EF),
                body: Center(child: CircularProgressIndicator()));
          }

          if (!userSnap.hasData || !userSnap.data!.exists) {
            return const Scaffold(
              body: Center(child: Text("User not found")),
            );
          }

          final userData = userSnap.data!.data()!;
          final role =
              (userData['role'] ?? 'customer').toString().toLowerCase();

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: providerStream(),
            builder: (context, providerSnap) {
              final providerData = providerSnap.data?.data();
              final status = (providerData?['status'] ?? 'pending')
                  .toString()
                  .toLowerCase();
              final skills =
                  (providerData?['skills'] as List<dynamic>?)?.join(', ') ?? '';
              final phone = providerData?['phoneNumber'] ?? 'N/A';
              final online = providerData?['online'] ?? false;

              return Scaffold(
                backgroundColor: const Color(0xFFF6F5EF),
                appBar: AppBar(title: const Text("Profile")),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          ElevatedButton(
                              onPressed: logout, child: const Text("Logout")),
                          const SizedBox(height: 20),

                          // CUSTOMER → Become a Provider form
                          if (role == 'customer')
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Become a Provider",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _inputField(
                                          controller: phoneController,
                                          hint: "Phone Number",
                                          icon: Icons.phone,
                                          keyboardType: TextInputType.phone,
                                        ),
                                        const SizedBox(height: 16),
                                        _inputField(
                                          controller: skillsController,
                                          hint:
                                              "Skills (e.g. Plumber, Electrician)",
                                          icon: Icons.build,
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : submitProviderForm,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: isLoading
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white)
                                                : const Text(
                                                    "Submit",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // PROVIDER PENDING
                          if (status == 'pending')
                            const Text(
                              "Your provider request is under review ⏳",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),

                          // VERIFIED PROVIDER → read-only card with Edit button
                          if (status == 'verified')
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Your Provider Profile",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Online status
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Available for jobs",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Icon(
                                        online
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            online ? Colors.green : Colors.red,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Phone
                                  Row(
                                    children: [
                                      const Icon(Icons.phone),
                                      const SizedBox(width: 12),
                                      Text(phone,
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Skills
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.build),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Text(skills,
                                              style: const TextStyle(
                                                  fontSize: 16))),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Edit button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const EditProviderProfileView(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text(
                                        "Edit Profile",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
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
