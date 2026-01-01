import 'package:cloud_firestore/cloud_firestore.dart';

class PayoutModel {
  final String id;
  final String providerId;
  final double amount;
  final String status; // requested, approved, paid
  final DateTime? createdAt;

  PayoutModel({
    required this.id,
    required this.providerId,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  factory PayoutModel.fromMap(String id, Map<String, dynamic> data) {
    return PayoutModel(
      id: id,
      providerId: data['providerId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'requested',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt,
    };
  }
}