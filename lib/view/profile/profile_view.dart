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

  String? role;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final uid = AuthServices().currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) return;

    setState(() {
      role = doc['role'] ?? 'customer';
    });
  }

  Future<void> submitProviderForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final uid = AuthServices().currentUser!.uid;

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
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': 'provider_pending',
    });

    setState(() {
      role = 'provider_pending';
      isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Provider request submitted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              const SizedBox(height: 30),

              if (role == 'customer') ...[
                const Text("Become a Provider",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        onPressed: isLoading ? null : submitProviderForm,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

              /// PROVIDER VERIFIED
              if (role == 'provider_verified') ...[
                const Text(
                  "You are a verified provider 🎉",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProviderProfileView(),
                      ),
                    );
                  },
                  child: const Text("Edit Provider Profile"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
