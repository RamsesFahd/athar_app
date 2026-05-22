import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/favorites/favorite_item_model.dart';

CulturalItemModel _makeCulturalItem() {
  return CulturalItemModel(
    id: 'cultural-1',
    titleAr: 'Title Ar',
    titleEn: 'Title En',
    descriptionAr: 'Description Ar',
    descriptionEn: 'Description En',
    imageUrl: 'image.png',
    categoryId: 'food',
    regionId: 'central',
    regionEn: 'Central Region',
    regionAr: 'Central Region Ar',
  );
}

TripModel _makeTrip() {
  return TripModel(
    id: 'trip-1',
    titleAr: 'Trip Ar',
    titleEn: 'Trip En',
    cityAr: 'Riyadh Ar',
    cityEn: 'Riyadh',
    guide: 'Guide',
    company: 'Company',
    adultPrice: 100,
    childPrice: 50,
    imageUrl: 'trip.png',
    descriptionAr: '',
    descriptionEn: '',
    license: '',
    shortDescriptionAr: '',
    shortDescriptionEn: '',
  );
}

void main() {
  group('FavoriteItemModel', () {
    test('UT-63: fromCultural copies cultural item identity and location', () {
      final favorite = FavoriteItemModel.fromCultural(_makeCulturalItem());

      expect(favorite.id, 'cultural-1');
      expect(favorite.itemId, 'cultural-1');
      expect(favorite.itemType, FavoriteItemType.cultural);
      expect(favorite.titleEn, 'Title En');
      expect(favorite.locationEn, 'Central Region');
    });

    test('UT-64: fromTrip copies trip identity and city', () {
      final favorite = FavoriteItemModel.fromTrip(_makeTrip());

      expect(favorite.id, 'trip-1');
      expect(favorite.itemId, 'trip-1');
      expect(favorite.itemType, FavoriteItemType.trip);
      expect(favorite.titleEn, 'Trip En');
      expect(favorite.locationEn, 'Riyadh');
    });

    test('UT-65: toMap/fromMap round-trip preserves saved item fields', () {
      final savedAt = DateTime(2025, 1, 1, 12, 0);
      final original = FavoriteItemModel(
        id: 'favorite-doc',
        itemId: 'trip-1',
        itemType: FavoriteItemType.trip,
        titleAr: 'Trip Ar',
        titleEn: 'Trip En',
        locationAr: 'Riyadh Ar',
        locationEn: 'Riyadh',
        imageUrl: 'trip.png',
        savedAt: savedAt,
      );

      final map = original.toMap();
      final restored = FavoriteItemModel.fromMap(map, 'favorite-doc');

      expect(map['savedAt'], isA<Timestamp>());
      expect(restored.id, original.id);
      expect(restored.itemId, original.itemId);
      expect(restored.itemType, original.itemType);
      expect(restored.titleEn, original.titleEn);
      expect(restored.locationEn, original.locationEn);
      expect(restored.savedAt, original.savedAt);
    });
  });
}
