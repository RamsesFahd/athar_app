import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';

enum RecommendedItemType { attraction, trip, event, culturalItem }

class RecommendedItem {
  final String id;
  final RecommendedItemType type;
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final List<String> interestIds;
  final int matchScore;
  final dynamic source;

  const RecommendedItem({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    required this.interestIds,
    required this.matchScore,
    required this.source,
  });

  factory RecommendedItem.fromAttraction(AttractionModel a, int matchScore) {
    return RecommendedItem(
      id: a.id,
      type: RecommendedItemType.attraction,
      titleAr: a.name['ar'] ?? a.name.values.firstOrNull ?? '',
      titleEn: a.name['en'] ?? a.name.values.firstOrNull ?? '',
      descriptionAr: a.description['ar'],
      descriptionEn: a.description['en'],
      imageUrl: a.mainImage,
      interestIds: a.interestIds,
      matchScore: matchScore,
      source: a,
    );
  }

  factory RecommendedItem.fromTrip(TripModel t, int matchScore) {
    return RecommendedItem(
      id: t.id,
      type: RecommendedItemType.trip,
      titleAr: t.titleAr,
      titleEn: t.titleEn,
      descriptionAr: t.descriptionAr,
      descriptionEn: t.descriptionEn,
      imageUrl: t.imageUrl,
      interestIds: t.interestIds,
      matchScore: matchScore,
      source: t,
    );
  }

  factory RecommendedItem.fromEvent(EventModel e, int matchScore) {
    return RecommendedItem(
      id: e.id,
      type: RecommendedItemType.event,
      titleAr: e.titleAr,
      titleEn: e.titleEn,
      descriptionAr: e.descriptionAr,
      descriptionEn: e.descriptionEn,
      imageUrl: e.imageUrl,
      interestIds: e.interestIds,
      matchScore: matchScore,
      source: e,
    );
  }

  factory RecommendedItem.fromCulturalItem(CulturalItemModel c, int matchScore) {
    return RecommendedItem(
      id: c.id,
      type: RecommendedItemType.culturalItem,
      titleAr: c.titleAr,
      titleEn: c.titleEn,
      descriptionAr: c.descriptionAr,
      descriptionEn: c.descriptionEn,
      imageUrl: c.imageUrl,
      interestIds: c.interestIds,
      matchScore: matchScore,
      source: c,
    );
  }
}
