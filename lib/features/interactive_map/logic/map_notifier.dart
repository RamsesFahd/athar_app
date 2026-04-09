import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/models/map/map_pin_model.dart';
import 'package:athar_app/features/interactive_map/logic/map_repository.dart';

part 'map_notifier.g.dart';

enum MapFilter { all, landmarks, events, nearMe }

class MapState {
  final List<MapPinModel> allPins;
  final List<MapPinModel> filteredPins;
  final MapFilter activeFilter;
  final String searchQuery;
  final MapPinModel? selectedPin;
  final bool isLoading;
  final bool locationGranted;

  const MapState({
    required this.allPins,
    required this.filteredPins,
    required this.activeFilter,
    required this.searchQuery,
    this.selectedPin,
    required this.isLoading,
    required this.locationGranted,
  });

  factory MapState.initial() => const MapState(
        allPins: [],
        filteredPins: [],
        activeFilter: MapFilter.all,
        searchQuery: '',
        selectedPin: null,
        isLoading: true,
        locationGranted: false,
      );

  MapState copyWith({
    List<MapPinModel>? allPins,
    List<MapPinModel>? filteredPins,
    MapFilter? activeFilter,
    String? searchQuery,
    Object? selectedPin = _sentinel,
    bool? isLoading,
    bool? locationGranted,
  }) {
    return MapState(
      allPins: allPins ?? this.allPins,
      filteredPins: filteredPins ?? this.filteredPins,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPin:
          selectedPin == _sentinel ? this.selectedPin : selectedPin as MapPinModel?,
      isLoading: isLoading ?? this.isLoading,
      locationGranted: locationGranted ?? this.locationGranted,
    );
  }
}

// Sentinel used to distinguish "not provided" from explicit null in copyWith
const Object _sentinel = Object();

@Riverpod(keepAlive: true)
class MapNotifier extends _$MapNotifier {
  @override
  FutureOr<MapState> build() async {
    return _loadPins();
  }

  Future<MapState> _loadPins() async {
    final repo = ref.read(mapRepositoryProvider);

    final landmarks = await repo.fetchLandmarksWithCoordinates();
    final events = await repo.fetchUpcomingEvents();

    final landmarkPins = landmarks.map((l) => MapPinModel(
          id: l.id,
          type: MapPinType.landmark,
          titleAr: l.titleAr,
          titleEn: l.titleEn,
          imageUrl: l.imageUrl,
          latitude: l.latitude!,
          longitude: l.longitude!,
          regionId: l.regionId,
          sourceModel: l,
        ));

    final eventPins = events.map((e) => MapPinModel(
          id: e.id,
          type: MapPinType.event,
          titleAr: e.titleAr,
          titleEn: e.titleEn,
          imageUrl: e.imageUrl,
          latitude: e.latitude,
          longitude: e.longitude,
          regionId: e.regionId,
          sourceModel: e,
        ));

    final allPins = [...landmarkPins, ...eventPins];

    return MapState(
      allPins: allPins,
      filteredPins: allPins,
      activeFilter: MapFilter.all,
      searchQuery: '',
      selectedPin: null,
      isLoading: false,
      locationGranted: false,
    );
  }

  void setFilter(MapFilter filter) {
    final current = state.value;
    if (current == null) return;

    // nearMe is handled asynchronously
    if (filter == MapFilter.nearMe) {
      _applyNearMeFilter(current);
      return;
    }

    final filtered = _applyFilters(current.allPins, filter, current.searchQuery);
    state = AsyncData(current.copyWith(
      activeFilter: filter,
      filteredPins: filtered,
      selectedPin: null,
    ));
  }

  void setSearchQuery(String query) {
    final current = state.value;
    if (current == null) return;

    final filtered = _applyFilters(current.allPins, current.activeFilter, query);
    state = AsyncData(current.copyWith(
      searchQuery: query,
      filteredPins: filtered,
    ));
  }

  void selectPin(MapPinModel? pin) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedPin: pin));
  }

  void setLocationGranted(bool granted) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(locationGranted: granted));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadPins);
  }

  Future<void> _applyNearMeFilter(MapState current) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      const double radiusMeters = 10000; // 10 km
      final nearby = current.allPins.where((pin) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          pin.latitude,
          pin.longitude,
        );
        return distance <= radiusMeters;
      }).toList();

      state = AsyncData(current.copyWith(
        activeFilter: MapFilter.nearMe,
        filteredPins: nearby,
        selectedPin: null,
      ));
    } catch (_) {
      // If location fails, fall back to showing all pins
      state = AsyncData(current.copyWith(
        activeFilter: MapFilter.all,
        filteredPins: current.allPins,
      ));
    }
  }

  List<MapPinModel> _applyFilters(
    List<MapPinModel> pins,
    MapFilter filter,
    String search,
  ) {
    return pins.where((pin) {
      final matchesFilter = filter == MapFilter.all ||
          (filter == MapFilter.landmarks && pin.type == MapPinType.landmark) ||
          (filter == MapFilter.events && pin.type == MapPinType.event);

      final matchesSearch = search.isEmpty ||
          pin.titleAr.contains(search) ||
          pin.titleEn.toLowerCase().contains(search.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }
}

// Derived providers
final filteredMapPinsProvider = Provider<List<MapPinModel>>((ref) {
  return ref.watch(mapNotifierProvider).value?.filteredPins ?? [];
});

final selectedMapPinProvider = Provider<MapPinModel?>((ref) {
  return ref.watch(mapNotifierProvider).value?.selectedPin;
});

final activeMapFilterProvider = Provider<MapFilter>((ref) {
  return ref.watch(mapNotifierProvider).value?.activeFilter ?? MapFilter.all;
});

final locationGrantedProvider = Provider<bool>((ref) {
  return ref.watch(mapNotifierProvider).value?.locationGranted ?? false;
});
