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

    final doc = await FirebaseFirestore.instance
        .collection('providers')
        .doc(uid)
        .get();

    final data = doc.data()!;
    phoneController.text = data['phoneNumber'] ?? '';
    skillsController.text = (data['skills'] as List).join(', ');
    online = data['online'] ?? false;

    setState(() => loading = false);
  }

  Future<void> saveChanges() async {
    final uid = AuthServices().currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('providers')
        .doc(uid)
        .update({
      'phoneNumber': phoneController.text.trim(),
      'skills': skillsController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      'online': online,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F5EF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                /// HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// FORM CARD
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
                    children: [
                      SwitchListTile(
                        title: const Text(
                          "Available for jobs",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Turn off if you are not accepting requests",
                        ),
                        value: online,
                        activeColor: Colors.green,
                        onChanged: (val) =>
                            setState(() => online = val),
                      ),

                      const SizedBox(height: 16),

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
                          onPressed: saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
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
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
