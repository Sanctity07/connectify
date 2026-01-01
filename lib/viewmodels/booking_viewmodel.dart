import 'package:cloud_firestore/cloud_firestore.dart';

class BookingViewModel {
  final _db = FirebaseFirestore.instance;

  Future<void> acceptJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'accepted',
    });
  }

  Future<void> declineJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'declined',
    });
  }

  Future<void> startJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'started',
    });
  }

  Future<void> completeJob(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'completed',
    });
  }
}
