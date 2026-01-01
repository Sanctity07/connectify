import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  offered,
  accepted,
  started,
  completed,
  cancelled,
  expired,
}

class BookingModel {
  final String id;
  final String customerId;
  final String? providerId; 
  final String serviceId;
  final String subServiceKey;
  final BookingStatus status;
  final DateTime? scheduledTime;
  final String address;
  final String description;
  final List<String> photos;
  final Map<String, dynamic>? pricingSnapshot; 
  final List<String> offerPool; 
  final Timestamp? createdAt;

  BookingModel({
    required this.id,
    required this.customerId,
    this.providerId,
    required this.serviceId,
    required this.subServiceKey,
    required this.status,
    this.scheduledTime,
    required this.address,
    required this.description,
    required this.photos,
    this.pricingSnapshot,
    required this.offerPool,
    this.createdAt,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> data) {
    return BookingModel(
      id: id,
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'],
      serviceId: data['serviceId'] ?? '',
      subServiceKey: data['subServiceKey'] ?? '',
      status: _statusFromString(data['status'] ?? 'pending'),
      scheduledTime: (data['scheduledTime'] as Timestamp?)?.toDate(),
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      pricingSnapshot: data['pricingSnapshot'],
      offerPool: List<String>.from(data['offerPool'] ?? []),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'providerId': providerId, 
      'serviceId': serviceId,
      'subServiceKey': subServiceKey,
      'status': _statusToString(status),
      'scheduledTime': scheduledTime != null ? Timestamp.fromDate(scheduledTime!) : null,
      'address': address,
      'description': description,
      'photos': photos,
      'pricingSnapshot': pricingSnapshot,
      'offerPool': offerPool,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  static BookingStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'offered':
        return BookingStatus.offered;
      case 'accepted':
        return BookingStatus.accepted;
      case 'started':
        return BookingStatus.started;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'expired':
        return BookingStatus.expired;
      default:
        return BookingStatus.pending;
    }
  }

  static String _statusToString(BookingStatus status) {
    return status.toString().split('.').last;
  }
}
