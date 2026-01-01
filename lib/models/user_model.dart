import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? address;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.address,
    this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      address: data['address'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'address': address,
      'createdAt': createdAt,
    };
  }
}