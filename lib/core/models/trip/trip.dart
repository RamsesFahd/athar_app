class Trip {
  final String id;
  // بدلاً من title واحد، نضع نسختين
  final String titleAr;
  final String titleEn;
  final String city; 
  final String guide;
  final String company;
  final String price;
  final String imageUrl;
  final String descriptionAr;
  final String descriptionEn; 
  final String license;
  final String shortDescriptionAr; 
  final String shortDescriptionEn; 

  Trip({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.city,
    required this.guide,
    required this.company,
    required this.price,
    required this.imageUrl,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.license,
    required this.shortDescriptionAr,
    required this.shortDescriptionEn,
  });

  // الدوال لاختيار النص حسب اللغة
  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
  String getDescription(bool isAr) => isAr ? descriptionAr : descriptionEn;
  String getShortDescription(bool isAr) => isAr ? shortDescriptionAr : shortDescriptionEn;
}