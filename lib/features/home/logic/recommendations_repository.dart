import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/home/models/recommended_item.dart';

class RecommendationsRepository {
  final FirebaseFirestore _firestore;

  RecommendationsRepository(this._firestore);

  Future<List<RecommendedItem>> fetchRecommendations(
    List<String> interests, {
    int limit = 8,
  }) async {
    if (interests.isEmpty) return const [];

    final interestSet = interests.toSet();

    final results = await Future.wait([
      _firestore.collection('attractions').get(),
      _firestore.collection('trips').get(),
      _firestore.collection('events').get(),
      _firestore.collection('cultural_items').get(),
    ]);

    final attractionsSnap = results[0];
    final tripsSnap = results[1];
    final eventsSnap = results[2];
    final culturalSnap = results[3];

    final items = <RecommendedItem>[];

    for (final doc in attractionsSnap.docs) {
      final model = AttractionModel.fromMap(doc.data(), doc.id);
      final score = model.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromAttraction(model, score));
    }

    for (final doc in tripsSnap.docs) {
      final model = TripModel.fromMap(doc.data(), doc.id);
      final score = model.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromTrip(model, score));
    }

    for (final doc in eventsSnap.docs) {
      final model = EventModel.fromMap(doc.data(), doc.id);
      final score = model.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromEvent(model, score));
    }

    for (final doc in culturalSnap.docs) {
      final model = CulturalItemModel.fromMap(doc.data(), doc.id);
      final score = model.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromCulturalItem(model, score));
    }

    items.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return items.take(limit).toList();
  }
}

final recommendationsRepositoryProvider = Provider<RecommendationsRepository>(
  (ref) => RecommendationsRepository(FirebaseFirestore.instance),
);

final homeRecommendationsProvider = FutureProvider.family<List<RecommendedItem>, List<String>>(
  (ref, interests) {
    final repo = ref.watch(recommendationsRepositoryProvider);
    return repo.fetchRecommendations(interests);
  },
);
