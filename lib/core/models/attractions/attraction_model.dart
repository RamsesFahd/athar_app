import 'package:cloud_firestore/cloud_firestore.dart';

class AttractionModel {
  static const allowedCategories = <String>[
    'Heritage',
    'Nature',
    'Arts',
    'Modern'
  ];

  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String category;
  final String categoryColorCode;
  // NEW: replaces `tags`. Holds IDs from /taxonomy collection (e.g., 'heritage_sites').
  final List<String> interestIds;
  // NEW: 768-dim semantic vector from Gemini text-embedding-004.
  // Used for Rawi's semantic search and future "similar items" features.
  final List<double> embedding;
  final String mainImage;
  final List<String> gallery;
  final String? videoUrl;
  final GeoPoint coordinates;
  final String region;
  final Map<String, String> city;
  final String address;
  final Map<String, String> openingHours;
  final bool isAlwaysOpen;
  final double entryFee;
  final String? ticketBookingUrl;

  const AttractionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.categoryColorCode,
    this.interestIds = const [],
    this.embedding = const [],
    required this.mainImage,
    required this.gallery,
    this.videoUrl,
    required this.coordinates,
    required this.region,
    required this.city,
    required this.address,
    required this.openingHours,
    required this.isAlwaysOpen,
    required this.entryFee,
    this.ticketBookingUrl,
  });

  String localizedText(Map<String, String> values, bool isAr) {
    final preferred = isAr ? values['ar'] : values['en'];
    if (preferred != null && preferred.trim().isNotEmpty) {
      return preferred.trim();
    }
    return values.values
        .firstWhere(
          (value) => value.trim().isNotEmpty,
          orElse: () => '',
        )
        .trim();
  }

  String getName(bool isAr) => localizedText(name, isAr);
  String getDescription(bool isAr) => localizedText(description, isAr);
  String getCity(bool isAr) => localizedText(city, isAr);
  String getOpeningHours(bool isAr) => localizedText(openingHours, isAr);

  bool get isValidCategory => allowedCategories.contains(category);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'categoryColorCode': categoryColorCode,
      'interestIds': interestIds,
      // embedding is intentionally excluded from manual saves — it's only
      // written by the Cloud Function. Skipping it here avoids overwriting
      // a valid embedding with an empty list during manual updates.
      'mainImage': mainImage,
      'gallery': gallery,
      'videoUrl': videoUrl,
      'coordinates': coordinates,
      'region': region,
      'city': city,
      'address': address,
      'openingHours': openingHours,
      'isAlwaysOpen': isAlwaysOpen,
      'entryFee': entryFee,
      'ticketBookingUrl': ticketBookingUrl,
    };
  }

  factory AttractionModel.fromMap(Map<String, dynamic> map, String docId) {
    final coordinates = map['coordinates'];
    final geoPoint = coordinates is GeoPoint
        ? coordinates
        : GeoPoint(
            (map['latitude'] as num?)?.toDouble() ?? 0,
            (map['longitude'] as num?)?.toDouble() ?? 0,
          );

    return AttractionModel(
      id: docId,
      name: _stringMap(map['name']),
      description: _stringMap(map['description']),
      category: (map['category'] ?? '').toString(),
      categoryColorCode: (map['categoryColorCode'] ?? '#344235').toString(),
      interestIds: (map['interestIds'] as List<dynamic>? ?? const [])
          .map((id) => id.toString())
          .where((id) => id.trim().isNotEmpty)
          .toList(),
      embedding: (map['embedding'] as List<dynamic>? ?? const [])
          .map((v) => (v as num).toDouble())
          .toList(),
      mainImage: (map['mainImage'] ?? '').toString(),
      gallery: (map['gallery'] as List<dynamic>? ?? const [])
          .map((image) => image.toString())
          .where((image) => image.trim().isNotEmpty)
          .toList(),
      videoUrl: map['videoUrl']?.toString(),
      coordinates: geoPoint,
      region: (map['region'] ?? '').toString(),
      city: _cityMap(map['city']),
      address: (map['address'] ?? '').toString(),
      openingHours: _stringMap(map['openingHours']),
      isAlwaysOpen: map['isAlwaysOpen'] as bool? ?? false,
      entryFee: (map['entryFee'] as num?)?.toDouble() ?? 0,
      ticketBookingUrl: map['ticketBookingUrl']?.toString(),
    );
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(
            key.toString(),
            value?.toString() ?? '',
          ));
    }
    return const <String, String>{};
  }

  static Map<String, String> _cityMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(
            key.toString(),
            value?.toString() ?? '',
          ));
    }
    final s = raw?.toString() ?? '';
    return {'ar': s, 'en': s};
  }
}
