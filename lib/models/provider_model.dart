class ProviderModel {
  final String id;
  final String userId;
  final String phoneNumber;
  final bool phoneVerified;
  final List<String> skills;
  final String status;
  final double ratingAvg;
  final int ratingCount;
  final bool online;
  final double balance;
  final double pendingPayout;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.phoneNumber,
    required this.phoneVerified,
    required this.skills,
    required this.status,
    required this.ratingAvg,
    required this.ratingCount,
    required this.online,
    required this.balance,
    required this.pendingPayout,
  });

  factory ProviderModel.fromMap(String id, Map<String, dynamic> data) {
    return ProviderModel(
      id: id,
      userId: data['userId'],
      phoneNumber: data['phoneNumber'] ?? '',
      phoneVerified: data['phoneVerified'] ?? false,
      skills: List<String>.from(data['skills'] ?? []),
      status: data['status'] ?? 'pending',
      ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      online: data['online'] ?? false,
      balance: (data['balance'] ?? 0).toDouble(),
      pendingPayout: (data['pendingPayout'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
      'skills': skills,
      'status': status,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'online': online,
      'balance': balance,
      'pendingPayout': pendingPayout,
    };
  }
}