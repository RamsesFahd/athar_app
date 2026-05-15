// Tests for TripsFilterNotifier.filterAndSort and state-mutation methods.
// UT-07 through UT-14.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/features/guide_market/logic/trips_filter_notifier.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';

// ---------------------------------------------------------------------------
// Helper — builds a TripModel with only the fields relevant to filter tests.
// ---------------------------------------------------------------------------
TripModel makeTrip({
  required String id,
  String titleAr = 'رحلة عامة',
  String titleEn = 'General Trip',
  String cityAr = 'الرياض',
  String cityEn = 'riyadh',
  double adultPrice = 1000,
}) {
  return TripModel(
    id: id,
    titleAr: titleAr,
    titleEn: titleEn,
    cityAr: cityAr,
    cityEn: cityEn,
    guide: 'Guide',
    company: 'Company',
    adultPrice: adultPrice,
    childPrice: 0,
    imageUrl: '',
    descriptionAr: '',
    descriptionEn: '',
    license: '',
    shortDescriptionAr: '',
    shortDescriptionEn: '',
  );
}

// ---------------------------------------------------------------------------
// Test data lists
// ---------------------------------------------------------------------------
List<TripModel> mixedTrips() => [
      makeTrip(id: '1', titleAr: 'رحلة الصحراء', titleEn: 'Desert Safari', cityEn: 'riyadh', adultPrice: 300),
      makeTrip(id: '2', titleAr: 'جولة الواحة', titleEn: 'Oasis Tour', cityEn: 'jeddah', adultPrice: 100),
      makeTrip(id: '3', titleAr: 'مغامرة الجبال', titleEn: 'Mountain Adventure', cityEn: 'abha', adultPrice: 200),
    ];

void main() {
  // Utility: create a fresh ProviderContainer with TripsFilterNotifier.
  ProviderContainer makeContainer() => ProviderContainer();

  group('TripsFilterNotifier', () {
    // UT-07 ----------------------------------------------------------------
    test('UT-07: Arabic search "رحلة" matches only the trip whose Arabic title contains that word', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);
      notifier.setSearchQuery('رحلة');

      final trips = mixedTrips();
      final result = notifier.filterAndSort(trips, true /* isAr */);

      expect(result.length, 1);
      expect(result.first.id, '1'); // 'رحلة الصحراء'
    });

    // UT-08 ----------------------------------------------------------------
    test('UT-08: English search "Desert" matches only the trip whose English title contains that word', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);
      notifier.setSearchQuery('Desert');

      final trips = mixedTrips();
      final result = notifier.filterAndSort(trips, false /* isEn */);

      expect(result.length, 1);
      expect(result.first.id, '1'); // 'Desert Safari'
    });

    // UT-09 ----------------------------------------------------------------
    test('UT-09: priceRange (5000, 6000) with all trips priced below 5000 → empty list', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);
      notifier.applyFilters(
        priceRange: const RangeValues(5000, 6000),
        cities: [],
        ascending: null,
      );

      final trips = mixedTrips(); // all < 5000
      final result = notifier.filterAndSort(trips, false);

      expect(result, isEmpty);
    });

    // UT-10 ----------------------------------------------------------------
    test('UT-10: selectedCities=["riyadh"] returns only Riyadh trips', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);
      notifier.applyFilters(
        priceRange: const RangeValues(0, 5000),
        cities: ['riyadh'],
        ascending: null,
      );

      final trips = mixedTrips(); // ids: riyadh, jeddah, abha
      final result = notifier.filterAndSort(trips, false);

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    // UT-11 ----------------------------------------------------------------
    test('UT-11: ascending sort returns trips ordered lowest to highest price', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);
      notifier.applyFilters(
        priceRange: const RangeValues(0, 5000),
        cities: [],
        ascending: true,
      );

      final trips = mixedTrips(); // prices: 300, 100, 200
      final result = notifier.filterAndSort(trips, false);

      expect(result.map((t) => t.adultPrice).toList(), [100, 200, 300]);
    });

    // UT-12 ----------------------------------------------------------------
    test('UT-12: descending sort returns trips ordered highest to lowest price', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);
      notifier.applyFilters(
        priceRange: const RangeValues(0, 5000),
        cities: [],
        ascending: false,
      );

      final trips = mixedTrips(); // prices: 300, 100, 200
      final result = notifier.filterAndSort(trips, false);

      expect(result.map((t) => t.adultPrice).toList(), [300, 200, 100]);
    });

    // UT-13 ----------------------------------------------------------------
    test('UT-13: filterAndSort with empty input list returns empty list', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);

      final result = notifier.filterAndSort([], false);
      expect(result, isEmpty);
    });

    // UT-14 ----------------------------------------------------------------
    test('UT-14: reset() reverts state to initial defaults after applyFilters', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tripsFilterProvider.notifier);
      notifier.setSearchQuery('Desert');
      notifier.applyFilters(
        priceRange: const RangeValues(1000, 3000),
        cities: ['jeddah'],
        ascending: true,
      );

      // Verify non-default state before reset
      final before = container.read(tripsFilterProvider);
      expect(before.searchQuery, 'Desert');
      expect(before.selectedCities, isNotEmpty);

      notifier.reset();

      final after = container.read(tripsFilterProvider);
      expect(after.searchQuery, '');
      expect(after.priceRange.start, 0);
      expect(after.priceRange.end, 5000);
      expect(after.selectedCities, isEmpty);
      expect(after.ascending, isNull);
    });
  });
}
