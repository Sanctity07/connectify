import 'package:cloud_functions/cloud_functions.dart';

class RatingViewModel {
  final HttpsCallable _submitRating =
      FirebaseFunctions.instance.httpsCallable('submitRating');

  Future<void> submitRating(String bookingId, int stars, String review) async {
    await _submitRating.call({
      'bookingId': bookingId,
      'stars': stars,
      'review': review,
    });
  }
}