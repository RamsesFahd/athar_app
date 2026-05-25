import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/notifications/logic/notifications_repository.dart';

part 'trip_management_repository.g.dart';

@riverpod
TripManagementRepository tripManagementRepository(Ref ref) {
  return TripManagementRepository();
}

class TripManagementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _trips => _firestore.collection('trips');
  CollectionReference get _users => _firestore.collection('users');

  Future<void> submitTrip(TripModel trip) async {
    await _trips.doc(trip.id).set(trip.toMap());
    final adminSnap =
        await _users.where('role', isEqualTo: UserRole.admin.name).get();
    final repo = NotificationsRepository();
    for (final doc in adminSnap.docs) {
      await repo.addNotification(
        userId: doc.id,
        type: 'trip_submitted',
      );
    }
  }

  Future<void> updateTrip(TripModel trip) async {
    await _trips.doc(trip.id).update(trip.toMap());
  }

  Future<void> deleteTrip(String tripId) async {
    await _trips.doc(tripId).delete();
  }

  Stream<List<TripModel>> fetchTutorTrips(String tutorId) {
    return _trips.where('tutorId', isEqualTo: tutorId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
