import 'package:flutter/material.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/viewmodels/customer_booking_viewmodel.dart';

class BookingFormView extends StatefulWidget {
  final String providerId;
  final String serviceId;
  final String subServiceKey;

  const BookingFormView({
    super.key,
    required this.providerId,
    required this.serviceId,
    required this.subServiceKey,
  });

  @override
  State<BookingFormView> createState() => _BookingFormViewState();
}

class _BookingFormViewState extends State<BookingFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool isLoading = false;

  Future<void> submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final uid = AuthServices().currentUser?.uid;
    if (uid == null) return;

    await CustomerBookingViewModel().createBooking(
      customerId: uid,
      providerId: widget.providerId,
      serviceId: widget.serviceId,
      subServiceKey: widget.subServiceKey,
      address: addressController.text.trim(),
      description: descController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking created successfully!")),
    );

    Navigator.pop(context);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                      "Book Provider",
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// SERVICE
                        Text(
                          "Service: ${widget.subServiceKey}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _inputField(
                          controller: addressController,
                          hint: "Address",
                          icon: Icons.location_on,
                          validator: (val) =>
                              val == null || val.isEmpty
                                  ? "Enter your address"
                                  : null,
                        ),

                        const SizedBox(height: 16),

                        _inputField(
                          controller: descController,
                          hint: "Description (optional)",
                          icon: Icons.description,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : submitBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Submit Booking",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
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
