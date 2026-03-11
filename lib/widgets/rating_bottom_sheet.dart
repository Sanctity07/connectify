// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:flutter/material.dart';

class RatingBottomSheet extends StatefulWidget {
  final String bookingId;
  final String providerId;

  const RatingBottomSheet({
    super.key,
    required this.bookingId,
    required this.providerId,
  });

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int selectedStars = 0;
  final reviewController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a star rating")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final customerId = AuthServices().currentUser!.uid;
    final db = FirebaseFirestore.instance;

    try {
      // 1. Write the rating document
      await db.collection('ratings').doc(widget.bookingId).set({
        'bookingId': widget.bookingId,
        'customerId': customerId,
        'providerId': widget.providerId,
        'stars': selectedStars,
        'review': reviewController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Recalculate provider average rating
      final ratingsSnap = await db
          .collection('ratings')
          .where('providerId', isEqualTo: widget.providerId)
          .get();

      final allStars = ratingsSnap.docs
          .map((d) => (d.data()['stars'] ?? 0) as int)
          .toList();

      final avg = allStars.isEmpty
          ? 0.0
          : allStars.reduce((a, b) => a + b) / allStars.length;

      await db.collection('providers').doc(widget.providerId).update({
        'ratingAvg': double.parse(avg.toStringAsFixed(1)),
        'ratingCount': allStars.length,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanks for your review!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Rate your experience",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Urbanist',
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "How was the service provided?",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 20),

          // Star selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return GestureDetector(
                onTap: () => setState(() => selectedStars = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    star <= selectedStars ? Icons.star : Icons.star_border,
                    size: 40,
                    color: star <= selectedStars
                        ? Colors.amber
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          Text(
            _ratingLabel(selectedStars),
            style: TextStyle(
              color: selectedStars > 0 ? Colors.amber.shade700 : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          // Review text field
          TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Leave a comment (optional)",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Review",
                      style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int stars) {
    return switch (stars) {
      1 => 'Poor',
      2 => 'Fair',
      3 => 'Good',
      4 => 'Very Good',
      5 => 'Excellent!',
      _ => 'Tap a star',
    };
  }
}