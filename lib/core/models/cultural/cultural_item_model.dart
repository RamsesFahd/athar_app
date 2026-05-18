import 'package:cloud_firestore/cloud_firestore.dart';

class CulturalItemModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imageUrl;       
  final String categoryId;   
  final String regionId;
  final String regionEn;
  final String regionAr;
  final DateTime? createdAt;
  final String? createdBy;
  final double? latitude;
  final double? longitude;
  final bool isContribution;
  final String? contributorId;
  final String? contributorName;
  final List<String> interestIds;

  CulturalItemModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
    required this.categoryId,
    required this.regionId,
    required this.regionEn,
    required this.regionAr,
    this.createdAt,
    this.createdBy,
    this.latitude,
    this.longitude,
    this.isContribution = false,
    this.contributorId,
    this.contributorName,
    this.interestIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'categoryId': categoryId, 
      'regionId': regionId,
      'regionEn': regionEn,
      'regionAr': regionAr,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isContribution': isContribution,
      if (contributorId != null) 'contributorId': contributorId,
      if (contributorName != null) 'contributorName': contributorName,
    };
  }

  factory CulturalItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return CulturalItemModel(
      id: docId,
      titleAr: map['titleAr'] ?? '',
      titleEn: map['titleEn'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      descriptionEn: map['descriptionEn'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      categoryId: map['categoryId'] ?? '',
      regionId: map['regionId'] ?? '',
      regionEn: map['regionEn'] ?? '',
      regionAr: map['regionAr'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      createdBy: map['createdBy'] ?? 'Admin',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isContribution: map['isContribution'] as bool? ?? false,
      contributorId: map['contributorId'] as String?,
      contributorName: map['contributorName'] as String?,
      interestIds: List<String>.from(map['interestIds'] ?? []),
    );
  }
}