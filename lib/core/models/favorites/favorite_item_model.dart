import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';

enum FavoriteItemType { cultural, trip }

class FavoriteItemModel {
  final String id;
  final String itemId;
  final FavoriteItemType itemType;
  final String titleAr;
  final String titleEn;
  final String locationAr;
  final String locationEn;
  final String imageUrl;
  final DateTime savedAt;
  final String? contributionId;

  const FavoriteItemModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.titleAr,
    required this.titleEn,
    required this.locationAr,
    required this.locationEn,
    required this.imageUrl,
    required this.savedAt,
    this.contributionId,
  });

  factory FavoriteItemModel.fromCultural(CulturalItemModel item) {
    return FavoriteItemModel(
      id: item.id,
      itemId: item.id,
      itemType: FavoriteItemType.cultural,
      titleAr: item.titleAr,
      titleEn: item.titleEn,
      locationAr: item.regionAr,
      locationEn: item.regionEn,
      imageUrl: item.imageUrl,
      savedAt: DateTime.now(),
      contributionId: item.isContribution ? item.contributionId : null,
    );
  }

  factory FavoriteItemModel.fromTrip(TripModel trip) {
    return FavoriteItemModel(
      id: trip.id,
      itemId: trip.id,
      itemType: FavoriteItemType.trip,
      titleAr: trip.titleAr,
      titleEn: trip.titleEn,
      locationAr: trip.cityAr,
      locationEn: trip.cityEn,
      imageUrl: trip.imageUrl,
      savedAt: DateTime.now(),
    );
  }

  factory FavoriteItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return FavoriteItemModel(
      id: docId,
      itemId: map['itemId'] as String? ?? '',
      itemType: FavoriteItemType.values.firstWhere(
        (e) => e.name == map['itemType'],
        orElse: () => FavoriteItemType.cultural,
      ),
      titleAr: map['titleAr'] as String? ?? '',
      titleEn: map['titleEn'] as String? ?? '',
      locationAr: map['locationAr'] as String? ?? '',
      locationEn: map['locationEn'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      savedAt: map['savedAt'] is Timestamp
          ? (map['savedAt'] as Timestamp).toDate()
          : DateTime.now(),
      contributionId: map['contributionId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'itemType': itemType.name,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'locationAr': locationAr,
        'locationEn': locationEn,
        'imageUrl': imageUrl,
        'savedAt': Timestamp.fromDate(savedAt),
        if (contributionId != null) 'contributionId': contributionId,
      };
}
