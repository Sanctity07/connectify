// ignore_for_file: deprecated_member_use

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
  final addressController = TextEditingController();
  final descController = TextEditingController();
  bool isLoading = false;
  late String selectedService;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  final List<String> availableServices = [
    'Cleaning',
    'IT Solutions',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Gardening',
    'Tutoring',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final passed = widget.subServiceKey.trim();
    // Try to match passed service to available list (case-insensitive)
    selectedService = availableServices.firstWhere(
      (s) => s.toLowerCase() == passed.toLowerCase(),
      orElse: () => availableServices.first,
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _scheduledTime = picked);
  }

  DateTime? get _combinedDateTime {
    if (_scheduledDate == null) return null;
    final t = _scheduledTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      t.hour,
      t.minute,
    );
  }

  String get _scheduledLabel {
    if (_scheduledDate == null) return 'Pick a date & time (optional)';
    final date =
        '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}';
    final t = _scheduledTime;
    final timeStr = t != null
        ? ' at ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
        : '';
    return '$date$timeStr';
  }

  Future<void> submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final uid = AuthServices().currentUser?.uid;
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      await CustomerBookingViewModel().createBooking(
        customerId: uid,
        providerId: widget.providerId,
        serviceId: widget.serviceId,
        subServiceKey: selectedService,
        address: addressController.text.trim(),
        description: descController.text.trim(),
        scheduledTime: _combinedDateTime,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking submitted! Waiting for provider."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

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

                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Book a Service",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Form card
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
                        // Service selection
                        const Text(
                          "What do you need?",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedService,
                              icon: const Icon(Icons.expand_more),
                              items: availableServices
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => selectedService = v);
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Address
                        const Text(
                          "Where?",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: addressController,
                          hint: "Address / Location",
                          icon: Icons.location_on_outlined,
                          validator: (val) => val == null || val.isEmpty
                              ? "Please enter your address"
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Description
                        const Text(
                          "Describe the job",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: descController,
                          hint:
                              "e.g. Fix leaking kitchen pipe, install power sockets...",
                          icon: Icons.description_outlined,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 20),

                        // Schedule
                        const Text(
                          "Schedule (optional)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: _scheduledDate != null
                                        ? Colors.deepPurple.withOpacity(0.08)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(30),
                                    border: _scheduledDate != null
                                        ? Border.all(
                                            color: Colors.deepPurple
                                                .withOpacity(0.3))
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: _scheduledDate != null
                                            ? Colors.deepPurple
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _scheduledDate != null
                                              ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                                              : 'Date',
                                          style: TextStyle(
                                            color: _scheduledDate != null
                                                ? Colors.deepPurple
                                                : Colors.grey,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: _scheduledTime != null
                                        ? Colors.deepPurple.withOpacity(0.08)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(30),
                                    border: _scheduledTime != null
                                        ? Border.all(
                                            color: Colors.deepPurple
                                                .withOpacity(0.3))
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_outlined,
                                        size: 16,
                                        color: _scheduledTime != null
                                            ? Colors.deepPurple
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _scheduledTime != null
                                            ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Time',
                                        style: TextStyle(
                                          color: _scheduledTime != null
                                              ? Colors.deepPurple
                                              : Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_scheduledDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.event_available,
                                  size: 14,
                                  color: Colors.deepPurple.withOpacity(0.7)),
                              const SizedBox(width: 6),
                              Text(
                                'Scheduled: $_scheduledLabel',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Colors.deepPurple.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : submitBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "Submit Booking",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info note
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 16,
                          color: Colors.deepPurple.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Your booking will be sent to the provider. You can chat with them once they accept.',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
