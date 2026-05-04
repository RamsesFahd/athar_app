enum MapPinType { landmark, attraction, event }

class MapPinModel {
  final String id;
  final MapPinType type;
  final String titleAr;
  final String titleEn;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String regionId;
  // The full source object (CulturalItemModel, AttractionModel, or EventModel) to avoid a second Firestore fetch on tap
  final Object sourceModel;
  // Only present for attraction pins — drives per-pin marker color
  final String? categoryColorCode;

  const MapPinModel({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.regionId,
    required this.sourceModel,
    this.categoryColorCode,
  });

  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
}
