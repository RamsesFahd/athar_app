import 'package:cloud_firestore/cloud_firestore.dart';

class RatingRepository {
  final CollectionReference _ratings =
      FirebaseFirestore.instance.collection('ratings');

  Future<bool> hasRated(String bookingId) async {
    final snap = await _ratings
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> submitRating({
    required String bookingId,
    required String touristId,
    required String tutorId,
    required String tripId,
    required int stars,
  }) async {
    await _ratings.add({
      'bookingId': bookingId,
      'touristId': touristId,
      'tutorId': tutorId,
      'tripId': tripId,
      'stars': stars,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
