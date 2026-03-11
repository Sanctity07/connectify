import 'package:cloud_firestore/cloud_firestore.dart';

class BookingViewModel {
  final _db = FirebaseFirestore.instance;

  Future<void> acceptJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> declineJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'declined',
      'declinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> startJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'started',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}