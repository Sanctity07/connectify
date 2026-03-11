import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String id;
  final String userId;
  final String username;
  final String phoneNumber;
  final bool phoneVerified;
  final List<String> skills;
  final String status;
  final double ratingAvg;
  final int ratingCount;
  final int completedJobs;
  final bool online;
  final double balance;
  final double pendingPayout;
  final String bio;
  final String profilePhotoUrl;
  final int yearsOfExperience;
  final String serviceArea;
  final List<String> portfolioPhotos;
  final DateTime? createdAt;

  ProviderModel({
    required this.id,
    required this.userId,
    this.username = '',
    required this.phoneNumber,
    required this.phoneVerified,
    required this.skills,
    required this.status,
    required this.ratingAvg,
    required this.ratingCount,
    this.completedJobs = 0,
    required this.online,
    required this.balance,
    required this.pendingPayout,
    this.bio = '',
    this.profilePhotoUrl = '',
    this.yearsOfExperience = 0,
    this.serviceArea = '',
    this.portfolioPhotos = const [],
    this.createdAt,
  });

  factory ProviderModel.fromMap(String id, Map<String, dynamic> data) {
    return ProviderModel(
      id: id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      phoneVerified: data['phoneVerified'] ?? false,
      skills: List<String>.from(data['skills'] ?? []),
      status: data['status'] ?? 'pending',
      ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      completedJobs: data['completedJobs'] ?? 0,
      online: data['online'] ?? false,
      balance: (data['balance'] ?? 0).toDouble(),
      pendingPayout: (data['pendingPayout'] ?? 0).toDouble(),
      bio: data['bio'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      serviceArea: data['serviceArea'] ?? '',
      portfolioPhotos: List<String>.from(data['portfolioPhotos'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
      'skills': skills,
      'status': status,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'completedJobs': completedJobs,
      'online': online,
      'balance': balance,
      'pendingPayout': pendingPayout,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'yearsOfExperience': yearsOfExperience,
      'serviceArea': serviceArea,
      'portfolioPhotos': portfolioPhotos,
    };
  }
}