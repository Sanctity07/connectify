import 'package:cloud_functions/cloud_functions.dart';

class ProviderViewModel {
  final HttpsCallable _requestApproval =
      FirebaseFunctions.instance.httpsCallable('requestProviderApproval');
  final HttpsCallable _approveProvider =
      FirebaseFunctions.instance.httpsCallable('approveProvider');

  Future<void> requestApproval(Map<String, dynamic> data) async {
    await _requestApproval.call(data);
  }

  Future<void> approveProvider(String uid) async {
    await _approveProvider.call({'uid': uid});
  }
}