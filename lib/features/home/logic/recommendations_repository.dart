import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/home/models/recommended_item.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/events/logic/events_repository.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';

// Derives recommendations from already-loaded stream providers — zero extra
// Firestore reads. Recomputes instantly whenever any source stream updates.
final homeRecommendationsProvider =
    Provider.family<AsyncValue<List<RecommendedItem>>, List<String>>(
  (ref, interests) {
    if (interests.isEmpty) return const AsyncValue.data([]);

    final attractionsAsync = ref.watch(attractionsStreamProvider);
    final tripsAsync = ref.watch(allTripsStreamProvider);
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);
    final culturalAsync = ref.watch(culturalNotifierProvider);

    if (attractionsAsync.isLoading ||
        tripsAsync.isLoading ||
        eventsAsync.isLoading ||
        culturalAsync.isLoading) {
      return const AsyncValue.loading();
    }

    final interestSet = interests.toSet();
    final items = <RecommendedItem>[];

    for (final a in attractionsAsync.valueOrNull ?? <AttractionModel>[]) {
      final score = a.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromAttraction(a, score));
    }

    for (final t in tripsAsync.valueOrNull ?? <TripModel>[]) {
      final score = t.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromTrip(t, score));
    }

    for (final e in eventsAsync.valueOrNull ?? <EventModel>[]) {
      final score = e.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromEvent(e, score));
    }

    for (final c
        in culturalAsync.valueOrNull?.allItems ?? <CulturalItemModel>[]) {
      final score = c.interestIds.where(interestSet.contains).length;
      if (score > 0) items.add(RecommendedItem.fromCulturalItem(c, score));
    }

    items.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return AsyncValue.data(items.take(8).toList());
  },
);
