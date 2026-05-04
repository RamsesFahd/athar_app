import 'package:cloud_firestore/cloud_firestore.dart';

enum ContributionStatus { pending, approved, rejected }

class ContributionModel {
  final String id;
  final String touristId;
  final String touristName;
  final String touristEmail;
  final String category;
  final String submissionLanguage; // 'ar' or 'en'
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String regionId;
  final String cityId;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final ContributionStatus status;
  final int points;
  final int likes;
  final int shares;
  final DateTime createdAt;
  final String? rejectionReason;
  final String? adminId;
  final String? adminName;
  final DateTime? reviewedAt;
  final String? archiveItemId;

  const ContributionModel({
    required this.id,
    required this.touristId,
    required this.touristName,
    required this.touristEmail,
    required this.category,
    required this.submissionLanguage,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.regionId,
    required this.cityId,
    required this.mediaUrl,
    required this.mediaType,
    required this.status,
    required this.points,
    required this.likes,
    required this.shares,
    required this.createdAt,
    this.rejectionReason,
    this.adminId,
    this.adminName,
    this.reviewedAt,
    this.archiveItemId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'touristId': touristId,
        'touristName': touristName,
        'touristEmail': touristEmail,
        'category': category,
        'submissionLanguage': submissionLanguage,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'descriptionAr': descriptionAr,
        'descriptionEn': descriptionEn,
        'regionId': regionId,
        'cityId': cityId,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'status': status.name,
        'points': points,
        'likes': likes,
        'shares': shares,
        'createdAt': Timestamp.fromDate(createdAt),
        'rejectionReason': rejectionReason,
        'adminId': adminId,
        'adminName': adminName,
        'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
        'archiveItemId': archiveItemId,
      };

  factory ContributionModel.fromMap(Map<String, dynamic> map, String id) {
    ContributionStatus parseStatus(String? raw) {
      return ContributionStatus.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => ContributionStatus.pending,
      );
    }

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return ContributionModel(
      id: id,
      touristId: map['touristId'] as String? ?? '',
      touristName: map['touristName'] as String? ?? '',
      touristEmail: map['touristEmail'] as String? ?? '',
      category: map['category'] as String? ?? '',
      submissionLanguage: map['submissionLanguage'] as String? ?? 'ar',
      titleAr: map['titleAr'] as String? ?? '',
      titleEn: map['titleEn'] as String? ?? '',
      descriptionAr: map['descriptionAr'] as String? ?? '',
      descriptionEn: map['descriptionEn'] as String? ?? '',
      regionId: map['regionId'] as String? ?? '',
      cityId: map['cityId'] as String? ?? '',
      mediaUrl: map['mediaUrl'] as String? ?? '',
      mediaType: map['mediaType'] as String? ?? 'image',
      status: parseStatus(map['status'] as String?),
      points: (map['points'] as num?)?.toInt() ?? 0,
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      shares: (map['shares'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(map['createdAt']),
      rejectionReason: map['rejectionReason'] as String?,
      adminId: map['adminId'] as String?,
      adminName: map['adminName'] as String?,
      reviewedAt: map['reviewedAt'] != null ? parseDate(map['reviewedAt']) : null,
      archiveItemId: map['archiveItemId'] as String?,
    );
  }

  ContributionModel copyWith({
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    ContributionStatus? status,
    int? points,
    String? rejectionReason,
    String? adminId,
    String? adminName,
    DateTime? reviewedAt,
    String? archiveItemId,
  }) {
    return ContributionModel(
      id: id,
      touristId: touristId,
      touristName: touristName,
      touristEmail: touristEmail,
      category: category,
      submissionLanguage: submissionLanguage,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      regionId: regionId,
      cityId: cityId,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      status: status ?? this.status,
      points: points ?? this.points,
      likes: likes,
      shares: shares,
      createdAt: createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      archiveItemId: archiveItemId ?? this.archiveItemId,
    );
  }

  String get displayTitle =>
      submissionLanguage == 'ar' ? titleAr : titleEn;
}
