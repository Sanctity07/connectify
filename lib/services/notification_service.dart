import 'package:cloud_firestore/cloud_firestore.dart';

/// Writes in-app notification documents to Firestore.
/// These are displayed in the NotificationsView.
class NotificationService {
  final _db = FirebaseFirestore.instance;

  Future<void> send({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? bookingId,
  }) async {
    try {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        if (bookingId != null) 'bookingId': bookingId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Notifications are non-critical — swallow errors
    }
  }
}
