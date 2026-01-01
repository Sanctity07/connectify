import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerBookingViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Customer creates a booking for a selected provider
  Future<void> createBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String subServiceKey,
    required String address,
    String description = '',
    DateTime? scheduledTime,
  }) async {
    final docRef = _firestore.collection('bookings').doc();

    await docRef.set({
      'customerId': customerId,
      'providerId': providerId,
      'serviceId': serviceId,
      'subServiceKey': subServiceKey,
      'status': 'pending', // waiting for provider
      'scheduledTime': scheduledTime ?? FieldValue.serverTimestamp(),
      'address': address,
      'description': description,
      'photos': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
