import 'package:cloud_firestore/cloud_firestore.dart';

class UserRewardModel {
  final String id;
  final String achievementId;
  final String type;
  final String titleAr;
  final String titleEn;
  final int pointsRequired;
  final bool isUsed;
  final DateTime? createdAt;
  final DateTime? usedAt;
  final String? bookingId;
  final DateTime? celebratedAt;

  const UserRewardModel({
    required this.id,
    required this.achievementId,
    required this.type,
    this.titleAr = '',
    this.titleEn = '',
    required this.pointsRequired,
    required this.isUsed,
    this.createdAt,
    this.usedAt,
    this.bookingId,
    this.celebratedAt,
  });

  factory UserRewardModel.fromMap(Map<String, dynamic> map, String id) {
    return UserRewardModel(
      id: id,
      achievementId: map['achievementId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      titleAr: map['titleAr'] as String? ?? '',
      titleEn: map['titleEn'] as String? ?? '',
      pointsRequired: (map['pointsRequired'] as num?)?.toInt() ?? 0,
      isUsed: map['isUsed'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      usedAt: (map['usedAt'] as Timestamp?)?.toDate(),
      bookingId: map['bookingId'] as String?,
      celebratedAt: (map['celebratedAt'] as Timestamp?)?.toDate(),
    );
  }
}
