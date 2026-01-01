import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:flutter/material.dart';

class EditProviderProfileView extends StatefulWidget {
  const EditProviderProfileView({super.key});

  @override
  State<EditProviderProfileView> createState() =>
      _EditProviderProfileViewState();
}

class _EditProviderProfileViewState extends State<EditProviderProfileView> {
  final phoneController = TextEditingController();
  final skillsController = TextEditingController();
  bool online = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final uid = AuthServices().currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance.collection('providers').doc(uid).get();

    final data = doc.data()!;
    phoneController.text = data['phoneNumber'] ?? '';
    skillsController.text = (data['skills'] as List).join(', ');
    online = data['online'] ?? false;

    setState(() => loading = false);
  }

  Future<void> saveChanges() async {
    final uid = AuthServices().currentUser!.uid;

    await FirebaseFirestore.instance.collection('providers').doc(uid).update({
      'phoneNumber': phoneController.text.trim(),
      'skills':
          skillsController.text.split(',').map((e) => e.trim()).toList(),
      'online': online,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Provider Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Available for jobs"),
              value: online,
              onChanged: (val) => setState(() => online = val),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: skillsController,
              decoration: const InputDecoration(
                labelText: "Skills (comma separated)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
