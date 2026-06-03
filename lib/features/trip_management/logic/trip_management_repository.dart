import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';

part 'trip_management_repository.g.dart';

@riverpod
TripManagementRepository tripManagementRepository(Ref ref) {
  return TripManagementRepository();
}

class TripManagementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _trips => _firestore.collection('trips');

  Future<void> submitTrip(TripModel trip) async {
    await _trips.doc(trip.id).set(trip.toMap());
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
