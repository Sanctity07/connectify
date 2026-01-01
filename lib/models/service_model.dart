// import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String category;
  final List<Map<String, dynamic>> subServices;
  final String pricingMode; 
  final double? price;
  final Map<String, double>? priceRange;
  final bool active;

  ServiceModel({
    required this.id,
    required this.category,
    required this.subServices,
    required this.pricingMode,
    this.price,
    this.priceRange,
    required this.active,
  });

  factory ServiceModel.fromMap(String id, Map<String, dynamic> data) {
    return ServiceModel(
      id: id,
      category: data['category'] ?? '',
      subServices: List<Map<String, dynamic>>.from(data['subServices'] ?? []),
      pricingMode: data['pricingMode'] ?? 'fixed',
      price: (data['price'] as num?)?.toDouble(),
      priceRange: data['priceRange'] != null
          ? {
              'min': (data['priceRange']['min'] as num).toDouble(),
              'max': (data['priceRange']['max'] as num).toDouble(),
            }
          : null,
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'subServices': subServices,
      'pricingMode': pricingMode,
      'price': price,
      'priceRange': priceRange,
      'active': active,
    };
  }
}