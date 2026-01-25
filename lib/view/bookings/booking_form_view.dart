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
      appBar: AppBar(
        title: const Text("Book Provider"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Service: ${widget.subServiceKey}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your address" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Booking",
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
