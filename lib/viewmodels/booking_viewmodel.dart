import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/notification_service.dart';

class BookingViewModel {
  final _db = FirebaseFirestore.instance;
  final _notif = NotificationService();

  Future<Map<String, dynamic>?> _getBooking(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    return doc.data();
  }

  Future<void> acceptJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    final booking = await _getBooking(bookingId);
    if (booking != null) {
      final service = booking['subServiceKey'] ?? 'Service';
      await _notif.send(
        userId: booking['customerId'],
        title: 'Booking Accepted! ✅',
        body: 'Your booking for "$service" has been accepted. The provider is on their way.',
        type: 'booking_accepted',
        bookingId: bookingId,
      );
    }
  }

  Future<void> declineJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'declined',
      'declinedAt': FieldValue.serverTimestamp(),
    });
    final booking = await _getBooking(bookingId);
    if (booking != null) {
      final service = booking['subServiceKey'] ?? 'Service';
      await _notif.send(
        userId: booking['customerId'],
        title: 'Booking Declined',
        body: 'Your booking for "$service" was declined. Please try another provider.',
        type: 'booking_declined',
        bookingId: bookingId,
      );
    }
  }

  Future<void> startJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'started',
      'startedAt': FieldValue.serverTimestamp(),
    });
    final booking = await _getBooking(bookingId);
    if (booking != null) {
      final service = booking['subServiceKey'] ?? 'Service';
      await _notif.send(
        userId: booking['customerId'],
        title: 'Job Started 🔧',
        body: 'Your "$service" job has started.',
        type: 'booking_started',
        bookingId: bookingId,
      );
    }
  }

  Future<void> completeJob(String bookingId) async {
    final booking = await _getBooking(bookingId);

    await _db.collection('bookings').doc(bookingId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    if (booking != null) {
      final service = booking['subServiceKey'] ?? 'Service';
      final providerId = booking['providerId'] ?? '';

      // Increment provider completedJobs counter
      if (providerId.isNotEmpty) {
        await _db.collection('providers').doc(providerId).update({
          'completedJobs': FieldValue.increment(1),
        });
      }

      await _notif.send(
        userId: booking['customerId'],
        title: 'Job Completed 🎉',
        body: 'Your "$service" job is complete. Please rate your experience.',
        type: 'booking_completed',
        bookingId: bookingId,
      );
    }
  }

  Future<void> cancelJob(String bookingId) async {
    final booking = await _getBooking(bookingId);

    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    if (booking != null) {
      final service = booking['subServiceKey'] ?? 'Service';
      await _notif.send(
        userId: booking['providerId'],
        title: 'Booking Cancelled',
        body: 'The customer cancelled their "$service" booking.',
        type: 'booking_cancelled',
        bookingId: bookingId,
      );
    }
  }
}
