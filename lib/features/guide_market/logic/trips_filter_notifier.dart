import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';

/// Immutable state for the trips list filter / sort controls.
class TripsFilter {
  final String searchQuery;
  final RangeValues priceRange;
  final List<String> selectedCities;
  final bool? ascending; // null = no sort applied

  const TripsFilter({
    this.searchQuery = '',
    this.priceRange = const RangeValues(0, 5000),
    this.selectedCities = const [],
    this.ascending,
  });

  bool get hasActiveFilters =>
      ascending != null ||
      selectedCities.isNotEmpty ||
      priceRange.start > 0 ||
      priceRange.end < 5000;

  TripsFilter copyWith({
    String? searchQuery,
    RangeValues? priceRange,
    List<String>? selectedCities,
    Object? ascending = _sentinel,
  }) {
    return TripsFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      priceRange: priceRange ?? this.priceRange,
      selectedCities: selectedCities ?? this.selectedCities,
      ascending: ascending == _sentinel ? this.ascending : ascending as bool?,
    );
  }
}

// Sentinel used so copyWith can pass null for ascending (clear sort).
const Object _sentinel = Object();

class TripsFilterNotifier extends AutoDisposeNotifier<TripsFilter> {
  @override
  TripsFilter build() => const TripsFilter();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void applyFilters({
    required RangeValues priceRange,
    required List<String> cities,
    required bool? ascending,
  }) {
    state = state.copyWith(
      priceRange: priceRange,
      selectedCities: cities,
      ascending: ascending,
    );
  }

  void reset() {
    state = const TripsFilter();
  }

  /// Pure filter+sort function. Accepts the full trip list and locale flag;
  /// returns the filtered/sorted result. Lives here so screens never embed
  /// business logic.
  List<TripModel> filterAndSort(List<TripModel> trips, bool isAr) {
    var result = trips;

    // 1. Text search
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.getTitle(isAr).toLowerCase().contains(q) ||
              t.company.toLowerCase().contains(q))
          .toList();
    }

    // 2. City filter (reserved for when TripModel exposes a city field)
    if (state.selectedCities.isNotEmpty) {
      result = result
          .where((t) => state.selectedCities
              .any((city) => t.getCity(isAr).contains(city)))
          .toList();
    }

    // 3. Price range filter
    result = result.where((t) {
      final price =
          int.tryParse(t.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return price >= state.priceRange.start && price <= state.priceRange.end;
    }).toList();

    // 4. Sort
    if (state.ascending != null) {
      result = List.from(result);
      result.sort((a, b) {
        final priceA =
            int.tryParse(a.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final priceB =
            int.tryParse(b.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return state.ascending! ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });
    }

    return result;
  }
}

final tripsFilterProvider =
    AutoDisposeNotifierProvider<TripsFilterNotifier, TripsFilter>(
  TripsFilterNotifier.new,
);