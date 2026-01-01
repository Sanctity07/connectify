import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final int stars;
  final String review;
  final DateTime? createdAt;

  RatingModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.stars,
    required this.review,
    this.createdAt,
  });

  factory RatingModel.fromMap(String id, Map<String, dynamic> data) {
    return RatingModel(
      id: id,
      bookingId: data['bookingId'] ?? '',
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      stars: data['stars'] ?? 0,
      review: data['review'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'providerId': providerId,
      'stars': stars,
      'review': review,
      'createdAt': createdAt,
    };
  }
}