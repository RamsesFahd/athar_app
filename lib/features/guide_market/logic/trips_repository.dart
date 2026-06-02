import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/utils/date_utils.dart';

part 'trips_repository.g.dart';

@riverpod
TripsRepository tripsRepository(Ref ref) {
  return TripsRepository();
}

class TripsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _trips => _firestore.collection('trips');
  CollectionReference get _bookings => _firestore.collection('bookings');
  CollectionReference get _users => _firestore.collection('users');


  Stream<List<TripModel>> fetchAllTrips() {
    return _trips
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<List<TutorModel>> fetchAvailableTutors() async {
    final query = await _users
        .where('role', isEqualTo: UserRole.tutor.name)
        .get();
    return query.docs
        .map((doc) => TutorModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Returns the set of dates (yyyy-MM-dd) that have an active (pending or
  /// approved) booking for the given trip. Used to block days in the date
  /// picker and to determine if a private trip is fully booked.
  Future<Set<String>> fetchBookedDates(String tripId) async {
    final snap = await _bookings
        .where('tripId', isEqualTo: tripId)
        .where('status', whereIn: ['pending', 'approved']).get();
    final Set<String> dates = {};
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dateStr = data['date'] as String? ?? '';
      if (dateStr.isEmpty) continue;
      final duration = (data['tripDurationDays'] as int?) ?? 1;
      final start = DateTime.tryParse(dateStr);
      if (start == null) continue;
      for (int i = 0; i < duration; i++) {
        final day = start.add(Duration(days: i));
        dates.add(fmtDate(day));
      }
    }
    return dates;
  }

  /// Returns the set of future dates (yyyy-MM-dd) where the individual guide
  /// already has an active booking on any trip OTHER than [currentTripId].
  /// Used to gray-out those days in the booking date picker.
  Future<Set<String>> fetchBookedDatesForGuide(
      String tutorId, String currentTripId) async {
    final todayStr = fmtDate(DateTime.now());
    final snap = await FirebaseFirestore.instance
        .collection('guide_slots')
        .where('tutorId', isEqualTo: tutorId)
        .where('date', isGreaterThanOrEqualTo: todayStr)
        .get();
    return snap.docs
        .where((d) => (d.data()['tripId'] as String?) != currentTripId)
        .map((d) => d.data()['date'] as String)
        .toSet();
  }

  Future<TutorModel?> fetchTutorById(String tutorId) async {
    final doc = await _users.doc(tutorId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;
    return TutorModel.fromMap(data);
  }

  Future<TripModel?> fetchTripById(String tripId) async {
    final doc = await _trips.doc(tripId).get();
    if (!doc.exists) return null;
    return TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}

// keepAlive: stream stays active across navigation so Home never re-fetches.
final allTripsStreamProvider = StreamProvider<List<TripModel>>((ref) {
  return ref.watch(tripsRepositoryProvider).fetchAllTrips();
});

final bookedDatesForTripProvider =
    FutureProvider.autoDispose.family<Set<String>, String>((ref, tripId) {
  return ref.read(tripsRepositoryProvider).fetchBookedDates(tripId);
});

/// Dates the individual guide is already committed to (on other trips).
/// Key: ({tutorId, currentTripId}) — currentTripId is excluded so that
/// multiple tourists can still book the same shared trip on that day.
final bookedDatesForGuideProvider = FutureProvider.autoDispose
    .family<Set<String>, ({String tutorId, String currentTripId})>(
  (ref, args) => ref
      .read(tripsRepositoryProvider)
      .fetchBookedDatesForGuide(args.tutorId, args.currentTripId),
);
