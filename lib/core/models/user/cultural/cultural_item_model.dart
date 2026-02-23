import 'package:cloud_firestore/cloud_firestore.dart';

class CulturalItemModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imageUrl;       
  final String categoryId;   // رابط للفئة
  final String regionEn;
  final String regionAr;
  final DateTime? createdAt; 
  final String? createdBy;


  CulturalItemModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
    required this.categoryId,
    required this.regionEn,
    required this.regionAr,
    this.createdAt,
    this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'categoryId': categoryId, 
      'regionEn': regionEn,
      'regionAr': regionAr,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
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
      regionEn: map['regionEn'] ?? '',
      regionAr: map['regionAr'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      createdBy: map['createdBy'] ?? 'Admin',
    );
  }
}