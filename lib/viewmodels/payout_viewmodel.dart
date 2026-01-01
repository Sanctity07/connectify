import 'package:cloud_functions/cloud_functions.dart';

class PayoutViewModel {
  final HttpsCallable _requestPayout =
      FirebaseFunctions.instance.httpsCallable('requestPayout');
  final HttpsCallable _approvePayout =
      FirebaseFunctions.instance.httpsCallable('approvePayout');

  /// Provider requests a payout
  Future<void> requestPayout(double amount) async {
    await _requestPayout.call({'amount': amount});
  }

  /// Admin approves payout (you can call this only if user has admin claim)
  Future<void> approvePayout(String payoutId) async {
    await _approvePayout.call({'payoutId': payoutId});
  }
}