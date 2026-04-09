enum MapPinType { landmark, event }

class MapPinModel {
  final String id;
  final MapPinType type;
  final String titleAr;
  final String titleEn;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String regionId;
  // The full source object (CulturalItemModel or EventModel) to avoid a second Firestore fetch on tap
  final Object sourceModel;

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
  });

  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
}
