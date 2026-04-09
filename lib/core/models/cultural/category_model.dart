class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      nameAr: map['nameAr'] ?? '',
      nameEn: map['nameEn'] ?? '',
    );
  }
}