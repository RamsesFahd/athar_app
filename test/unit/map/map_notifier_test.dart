import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/models/map/map_pin_model.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';
import 'package:athar_app/features/interactive_map/logic/map_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMapRepository extends Mock implements MapRepository {}

CulturalItemModel _landmark() {
  return CulturalItemModel(
    id: 'landmark-1',
    titleAr: 'Landmark Ar',
    titleEn: 'Landmark En',
    descriptionAr: '',
    descriptionEn: '',
    imageUrl: 'landmark.png',
    categoryId: 'history',
    regionId: 'central',
    regionEn: 'Central',
    regionAr: 'Central Ar',
    latitude: 24.7136,
    longitude: 46.6753,
  );
}

AttractionModel _attraction() {
  return const AttractionModel(
    id: 'attraction-1',
    name: {'ar': 'Attraction Ar', 'en': 'Attraction En'},
    description: {'ar': '', 'en': ''},
    category: 'Heritage',
    categoryColorCode: '#344235',
    mainImage: 'attraction.png',
    gallery: [],
    coordinates: GeoPoint(21.4858, 39.1925),
    region: 'western',
    city: {'ar': 'Jeddah Ar', 'en': 'Jeddah'},
    address: '',
    openingHours: {},
    isAlwaysOpen: true,
    entryFee: 0,
  );
}

EventModel _event() {
  return EventModel(
    id: 'event-1',
    titleAr: 'Event Ar',
    titleEn: 'Event En',
    descriptionAr: '',
    descriptionEn: '',
    imageUrl: 'event.png',
    eventDate: DateTime(2025, 1, 1),
    timeAr: '',
    timeEn: '',
    latitude: 26.4207,
    longitude: 50.0888,
    regionId: 'eastern',
    regionAr: 'Eastern Ar',
    regionEn: 'Eastern',
    categoryId: 'festival',
    eventType: EventType.festival,
    isFree: true,
  );
}

void main() {
  group('MapPinModel', () {
    test('UT-82: getTitle returns Arabic or English title by locale flag', () {
      const pin = MapPinModel(
        id: 'pin-1',
        type: MapPinType.landmark,
        titleAr: 'Title Ar',
        titleEn: 'Title En',
        imageUrl: '',
        latitude: 1,
        longitude: 2,
        regionId: 'central',
        sourceModel: 'source',
      );

      expect(pin.getTitle(true), 'Title Ar');
      expect(pin.getTitle(false), 'Title En');
    });
  });

  group('MapState', () {
    test('UT-83: copyWith can preserve or clear selectedPin explicitly', () {
      const pin = MapPinModel(
        id: 'pin-1',
        type: MapPinType.landmark,
        titleAr: 'Title Ar',
        titleEn: 'Title En',
        imageUrl: '',
        latitude: 1,
        longitude: 2,
        regionId: 'central',
        sourceModel: 'source',
      );
      final state = MapState.initial().copyWith(selectedPin: pin);

      final preserved = state.copyWith(searchQuery: 'q');
      final cleared = state.copyWith(selectedPin: null);

      expect(preserved.selectedPin, pin);
      expect(cleared.selectedPin, isNull);
    });
  });

  group('MapNotifier', () {
    late MockMapRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = MockMapRepository();
      when(() => repo.fetchLandmarksWithCoordinates())
          .thenAnswer((_) async => [_landmark()]);
      when(() => repo.fetchAttractionsWithCoordinates())
          .thenAnswer((_) async => [_attraction()]);
      when(() => repo.fetchUpcomingEvents())
          .thenAnswer((_) async => [_event()]);

      container = ProviderContainer(
        overrides: [
          mapRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('UT-84: build converts repository models into map pins', () async {
      final state = await container.read(mapNotifierProvider.future);

      expect(state.allPins.length, 3);
      expect(state.filteredPins.length, 3);
      expect(state.allPins.map((pin) => pin.type).toList(), [
        MapPinType.landmark,
        MapPinType.attraction,
        MapPinType.event,
      ]);
      expect(state.isLoading, isFalse);
    });

    test('UT-85: setFilter shows only event pins', () async {
      await container.read(mapNotifierProvider.future);

      container.read(mapNotifierProvider.notifier).setFilter(MapFilter.events);

      final state = container.read(mapNotifierProvider).value!;

      expect(state.activeFilter, MapFilter.events);
      expect(state.filteredPins.length, 1);
      expect(state.filteredPins.first.type, MapPinType.event);
    });

    test('UT-86: setSearchQuery filters pins by English title', () async {
      await container.read(mapNotifierProvider.future);

      container.read(mapNotifierProvider.notifier).setSearchQuery('landmark');

      final state = container.read(mapNotifierProvider).value!;

      expect(state.searchQuery, 'landmark');
      expect(state.filteredPins.map((pin) => pin.id).toList(), ['landmark-1']);
    });

    test('UT-87: selectPinById selects matching pin', () async {
      await container.read(mapNotifierProvider.future);

      container.read(mapNotifierProvider.notifier).selectPinById('event-1');

      final selected = container.read(selectedMapPinProvider);

      expect(selected?.id, 'event-1');
    });

    test('UT-88: setLocationGranted updates derived location provider',
        () async {
      await container.read(mapNotifierProvider.future);

      container.read(mapNotifierProvider.notifier).setLocationGranted(true);

      expect(container.read(locationGrantedProvider), isTrue);
    });
  });
}
