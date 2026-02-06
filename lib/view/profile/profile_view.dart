import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/view/auth/login_view.dart';
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final uid = AuthServices().currentUser?.uid;
    if (uid == null) throw Exception("No logged-in user");
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _providerStream(String uid) {
    return FirebaseFirestore.instance
        .collection('providers')
        .doc(uid)
        .snapshots();
  }

  Future<void> submitProviderForm(String uid) async {
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
      stream: _userStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("User not found")));
        }

        final userData = userSnapshot.data!.data()!;
        final role = userData['role'] ?? 'customer';
        final uid = AuthServices().currentUser!.uid;

        return Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Logout button
                  ElevatedButton(
                    onPressed: () async {
                      await AuthServices().logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (_) => false,
                      );
                    },
                    child: const Text("Logout"),
                  ),
                  const SizedBox(height: 20),

                  /// CUSTOMER ROLE
                  if (role == 'customer') ...[
                    const Text(
                      "Become a Provider",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: "Phone Number",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: skillsController,
                            decoration: const InputDecoration(
                              labelText: "Skills (comma separated)",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => submitProviderForm(uid),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text("Submit"),
                          ),
                        ],
                      ),
                    ),
                  ],

                  /// PROVIDER PENDING
                  if (role == 'provider_pending')
                    const Text(
                      "Your provider request is under review ⏳",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                  /// PROVIDER VERIFIED
                  if (role == 'provider_verified')
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _providerStream(uid),
                      builder: (context, providerSnapshot) {
                        if (!providerSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final providerData = providerSnapshot.data!.data()!;
                        phoneController.text =
                            providerData['phoneNumber'] ?? '';
                        skillsController.text =
                            (providerData['skills'] as List<dynamic>?)
                                    ?.join(', ') ??
                                '';

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Your Provider Info",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: phoneController,
                                  decoration: const InputDecoration(
                                    labelText: "Phone Number",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: skillsController,
                                  decoration: const InputDecoration(
                                    labelText: "Skills (comma separated)",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: () async {
                                    final phone = phoneController.text.trim();
                                    final skills = skillsController.text
                                        .split(',')
                                        .map((e) => e.trim())
                                        .toList();

                                    await FirebaseFirestore.instance
                                        .collection('providers')
                                        .doc(uid)
                                        .update({
                                      'phoneNumber': phone,
                                      'skills': skills,
                                    });

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Provider info updated")),
                                    );
                                  },
                                  child: const Text("Save Changes"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
