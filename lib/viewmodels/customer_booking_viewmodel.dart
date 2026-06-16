import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/notification_service.dart';

class CustomerBookingViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _notif = NotificationService();

  /// Customer creates a booking for a selected provider.
  Future<String> createBooking({
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
      'status': 'pending',
      'scheduledTime':
          scheduledTime != null ? Timestamp.fromDate(scheduledTime) : null,
      'address': address,
      'description': description,
      'photos': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify provider of new booking request
    final customerDoc =
        await _firestore.collection('users').doc(customerId).get();
    final customerName =
        customerDoc.data()?['username'] ?? 'A customer';

    await _notif.send(
      userId: providerId,
      title: 'New Booking Request 🔔',
      body: '$customerName booked you for "$subServiceKey". Tap to respond.',
      type: 'booking_new',
      bookingId: docRef.id,
    );

    return docRef.id;
  }
}
