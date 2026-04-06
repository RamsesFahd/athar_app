import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String cityAr;
  final String cityEn;
  final String guide;
  final String company;
  final double adultPrice;
  final double childPrice; // 0.0 = free for children
  final String imageUrl;
  final String descriptionAr;
  final String descriptionEn;
  final String license;
  final String shortDescriptionAr;
  final String shortDescriptionEn;
  final String? tutorId;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String tutorType; // 'individual' | 'company'
  final List<String> accessibilityFeatures; // e.g. ['wheelchair', 'family']

  TripModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.cityAr,
    required this.cityEn,
    required this.guide,
    required this.company,
    required this.adultPrice,
    required this.childPrice,
    required this.imageUrl,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.license,
    required this.shortDescriptionAr,
    required this.shortDescriptionEn,
    this.tutorId,
    this.status = 'approved',
    this.tutorType = 'individual',
    this.accessibilityFeatures = const [],
  });

  /// Display helper used in TripCard / TripDetailsScreen (shows adult price).
  String get price => '${adultPrice.toInt()} ر.س';

  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
  String getDescription(bool isAr) => isAr ? descriptionAr : descriptionEn;
  String getShortDescription(bool isAr) =>
      isAr ? shortDescriptionAr : shortDescriptionEn;

  factory TripModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Backward-compat: old docs stored price as a string like "400 ر.س"
    double parsePrice(dynamic raw) {
      if (raw == null) return 0.0;
      if (raw is num) return raw.toDouble();
      final cleaned = raw.toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    return TripModel(
      id: documentId,
      titleAr: map['titleAr'] ?? '',
      titleEn: map['titleEn'] ?? '',
      cityAr: map['cityAr'] ?? map['city'] ?? '',
      cityEn: map['cityEn'] ?? map['city'] ?? '',
      guide: map['guide'] ?? '',
      company: map['company'] ?? '',
      adultPrice: parsePrice(map['adultPrice'] ?? map['price']),
      childPrice: parsePrice(map['childPrice']),
      imageUrl: map['imageUrl'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      descriptionEn: map['descriptionEn'] ?? '',
      license: map['license'] ?? '',
      shortDescriptionAr: map['shortDescriptionAr'] ?? '',
      shortDescriptionEn: map['shortDescriptionEn'] ?? '',
      tutorId: map['tutorId'],
      status: map['status'] ?? 'approved',
      tutorType: map['tutorType'] ?? 'individual',
      accessibilityFeatures:
          List<String>.from(map['accessibilityFeatures'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'cityAr': cityAr,
      'cityEn': cityEn,
      'guide': guide,
      'company': company,
      'adultPrice': adultPrice,
      'childPrice': childPrice,
      'imageUrl': imageUrl,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'license': license,
      'shortDescriptionAr': shortDescriptionAr,
      'shortDescriptionEn': shortDescriptionEn,
      'tutorId': tutorId,
      'status': status,
      'tutorType': tutorType,
      'accessibilityFeatures': accessibilityFeatures,
    };
  }
  String getCity(bool isAr) => isAr ? cityAr : cityEn;
}
