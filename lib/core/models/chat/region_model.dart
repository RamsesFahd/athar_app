class RegionModel {
  final String regionId;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String image;
  final String systemPrompt; // التعليمات البرمجية الخاصة بكل منطقة

  RegionModel({
    required this.regionId,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.image,
    required this.systemPrompt,
  });

  String getName(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
  String getDescription(String languageCode) => languageCode == 'ar' ? descriptionAr : descriptionEn;
}