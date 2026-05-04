import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';

part 'map_repository.g.dart';

@Riverpod(keepAlive: true)
MapRepository mapRepository(Ref ref) {
  return MapRepository(ref: ref);
}

class MapRepository {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MapRepository({required Ref ref}) : _ref = ref;

  CollectionReference get _events => _firestore.collection('events');
  CollectionReference get _attractions => _firestore.collection('attractions');

  /// Returns cultural items that have coordinates — reuses the CulturalRepository cache.
  Future<List<CulturalItemModel>> fetchLandmarksWithCoordinates() async {
    final repo = _ref.read(culturalRepositoryProvider);
    final allItems = await repo.fetchItems();
    return allItems
        .where((item) => item.latitude != null && item.longitude != null)
        .toList();
  }

  /// Returns attractions that have valid coordinates.
  Future<List<AttractionModel>> fetchAttractionsWithCoordinates() async {
    final snapshot = await _attractions.orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map(
          (doc) => AttractionModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .where(
          (item) => item.coordinates.latitude != 0 || item.coordinates.longitude != 0,
        )
        .toList();
  }

  /// Returns all upcoming events (eventDate >= now).
  Future<List<EventModel>> fetchUpcomingEvents() async {
    final snapshot = await _events
        .where('eventDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('eventDate')
        .get();

    return snapshot.docs
        .map((doc) =>
            EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
