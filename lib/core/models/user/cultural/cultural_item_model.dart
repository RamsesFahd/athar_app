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
  });

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'categoryId': categoryId, // مهم لربط العنصر بالفئة
      'regionEn': regionEn,
      'regionAr': regionAr,
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
    );
  }
}