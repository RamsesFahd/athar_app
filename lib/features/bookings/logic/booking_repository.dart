import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/contribution/user_reward_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/utils/booking_schedule_helper.dart';
import 'package:athar_app/core/utils/date_utils.dart';
import 'package:cloud_functions/cloud_functions.dart';

part 'booking_repository.g.dart';

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository();
}

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _bookings => _firestore.collection('bookings');
  CollectionReference get _trips => _firestore.collection('trips');
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _slots => _firestore.collection('guide_slots');

  Future<void> createBooking(BookingModel booking) async {
    // 1. Enforce 24-hour advance booking requirement
    final tripDate = DateTime.tryParse(booking.date);
    final scheduledStart = bookingScheduledStart(booking);
    final cutoff = DateTime.now().add(const Duration(hours: 24));
    if (tripDate == null || scheduledStart == null || !scheduledStart.isAfter(cutoff)) {
      throw Exception('bookingTooCloseError');
    }

    // 2. Fetch trip type and tutor type needed for slot conflict checks
    final tripDoc = await _trips.doc(booking.tripId).get();
    final tripData = tripDoc.data() as Map<String, dynamic>?;
    final tripType = tripData?['tripType'] as String? ?? 'shared';
    final tutorType = tripData?['tutorType'] as String? ?? 'individual';

    // 3. Expand booking into all dates it spans (multi-day trips)
    final newDates = <String>{
      for (int i = 0; i < (booking.tripDurationDays ?? 1); i++)
        fmtDate(tripDate.add(Duration(days: i))),
    };

    final bookingRef = _bookings.doc(booking.bookingId);
    DocumentReference? rewardRef;
    if (booking.rewardId != null) {
      rewardRef = _users
          .doc(booking.touristId)
          .collection('rewards')
          .doc(booking.rewardId);
    }

    // Firestore requires all reads to precede any writes within a transaction
    await _firestore.runTransaction((tx) async {
      // 5a. Read all slot docs upfront (Firestore forbids reads after writes)
      final Map<String, DocumentSnapshot> cachedSlots = {};
      if (tripType == 'private' || tutorType == 'individual') {
        for (final date in newDates) {
          cachedSlots[date] =
              await tx.get(_slots.doc('${booking.tutorId}_$date'));
        }
      }

      // 5b. Private-trip day conflict: any existing slot blocks a new booking
      if (tripType == 'private') {
        for (final date in newDates) {
          if (cachedSlots.containsKey(date) && cachedSlots[date]!.exists) {
            throw Exception('tripDayAlreadyBookedError');
          }
        }
      }

      // 5c. Individual-guide cross-trip conflict
      if (tutorType == 'individual') {
        for (final date in newDates) {
          final snap = cachedSlots[date];
          if (snap == null) continue;
          final slotTripId =
              (snap.data() as Map<String, dynamic>?)?['tripId'] as String?;
          if (snap.exists && slotTripId != booking.tripId) {
            throw Exception('tutorNotAvailableError');
          }
        }
      }

      // 5d. Reward validation
      if (rewardRef != null) {
        final rewardSnap = await tx.get(rewardRef);
        final isUsed =
            (rewardSnap.data() as Map<String, dynamic>?)?['isUsed'] as bool? ??
                true;
        if (!rewardSnap.exists || isUsed) {
          throw Exception('rewardUnavailable');
        }
        tx.update(rewardRef, {
          'isUsed': true,
          'usedAt': FieldValue.serverTimestamp(),
          'bookingId': booking.bookingId,
        });
      }

      // 5e. Write booking — include tutorType and tripType for later cleanup use
      tx.set(bookingRef, {
        ...booking.toMap(),
        'tutorType': tutorType,
        'tripType': tripType,
      });

      // 5f. Write slot docs using cached reads — no tx.get after writes
      if (tutorType == 'individual' || tripType == 'private') {
        for (final date in newDates) {
          if (cachedSlots[date] != null && !cachedSlots[date]!.exists) {
            tx.set(_slots.doc('${booking.tutorId}_$date'), {
              'tutorId': booking.tutorId,
              'date': date,
              'tripId': booking.tripId,
            });
          }
        }
      }
    });
  }

  // Deletes the slot for each date in [dates] only if no remaining
  // pending/approved bookings for the same (tutorId, tripId) still cover it.
  // One query is enough — we expand each booking's date range in Dart.
  Future<void> _cleanupSlotsIfEmpty({
    required String tutorId,
    required String tripId,
    required Set<String> dates,
    required WriteBatch batch,
  }) async {
    final remaining = await _bookings
        .where('tutorId', isEqualTo: tutorId)
        .where('tripId', isEqualTo: tripId)
        .where('status', whereIn: ['pending', 'approved']).get();

    final stillActiveDates = <String>{};
    for (final doc in remaining.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final bookingDate = data['date'] as String? ?? '';
      final dur = (data['tripDurationDays'] as int?) ?? 1;
      final start = DateTime.tryParse(bookingDate);
      if (start == null) continue;
      for (int i = 0; i < dur; i++) {
        stillActiveDates.add(fmtDate(start.add(Duration(days: i))));
      }
    }

    for (final date in dates) {
      if (!stillActiveDates.contains(date)) {
        batch.delete(_slots.doc('${tutorId}_$date'));
      }
    }
  }

  Stream<List<BookingModel>> fetchUserBookings(String userId, UserRole role) {
    final String field = (role == UserRole.tutor) ? 'tutorId' : 'touristId';
    return _bookings
        .where(field, isEqualTo: userId)
        .limit(100)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map(
              (doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<List<BookingModel>> fetchUserBookingsOnce(
      String userId, UserRole role) async {
    final String field = (role == UserRole.tutor) ? 'tutorId' : 'touristId';
    final snapshot = await _bookings.where(field, isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptBooking(String bookingId, String touristId) async {
    final batch = _firestore.batch();
    batch.update(_bookings.doc(bookingId), {
      'status': BookingStatus.approved.name,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
    String touristId,
  ) async {
    // Fetch booking once — used for reward restore + slot cleanup
    final bookingSnap = await _bookings.doc(bookingId).get();
    final bookingData = bookingSnap.data() as Map<String, dynamic>?;

    final batch = _firestore.batch();
    batch.update(_bookings.doc(bookingId), {'status': status.name});

    if (status == BookingStatus.cancelled || status == BookingStatus.rejected) {
      // Restore reward if one was used
      final rewardId = bookingData?['rewardId'] as String?;
      if (rewardId != null && rewardId.isNotEmpty) {
        batch.update(
          _users.doc(touristId).collection('rewards').doc(rewardId),
          {'isUsed': false, 'usedAt': null, 'bookingId': null},
        );
      }
    }

    await batch.commit();

    // Slot cleanup runs after batch so the new status is visible to the query
    if ((status == BookingStatus.cancelled ||
            status == BookingStatus.rejected) &&
        bookingSnap.exists &&
        ((bookingData?['tutorType'] as String?) == 'individual' ||
            (bookingData?['tripType'] as String?) == 'private')) {
      final tutorId = bookingData?['tutorId'] as String? ?? '';
      final tripId = bookingData?['tripId'] as String? ?? '';
      final date = bookingData?['date'] as String? ?? '';
      final dur = (bookingData?['tripDurationDays'] as int?) ?? 1;
      if (tutorId.isNotEmpty && tripId.isNotEmpty && date.isNotEmpty) {
        final dates = {
          for (int i = 0; i < dur; i++)
            fmtDate(DateTime.parse(date).add(Duration(days: i))),
        };
        final cleanupBatch = _firestore.batch();
        await _cleanupSlotsIfEmpty(
          tutorId: tutorId,
          tripId: tripId,
          dates: dates,
          batch: cleanupBatch,
        );
        await cleanupBatch.commit();
      }
    }
  }

  Future<void> markBookingCompleted(String bookingId) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'markBookingCompleted',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    await callable.call(<String, dynamic>{'bookingId': bookingId});
  }

  Stream<List<UserRewardModel>> watchUnusedRewards(String userId) {
    return _users
        .doc(userId)
        .collection('rewards')
        .where('isUsed', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => UserRewardModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Returns remaining available seats for [tripId] on [date] (YYYY-MM-DD).
  /// Emits null when the trip has no capacity limit or no booking has happened
  /// yet for that date (meaning full maxCapacity is still available).
  Stream<int?> watchAvailableSeatsForDate(String tripId, String date) {
    if (date.isEmpty) return Stream.value(null);
    return _firestore
        .collection('trip_capacity')
        .doc('${tripId}_$date')
        .snapshots()
        .map((snap) {
          if (!snap.exists) return null;
          final data = snap.data();
          if (data == null) return null;
          return data['availableSeats'] as int?;
        });
  }
}

final unusedRewardsProvider =
    StreamProvider.autoDispose.family<List<UserRewardModel>, String>(
  (ref, userId) {
    return ref.watch(bookingRepositoryProvider).watchUnusedRewards(userId);
  },
);

/// Key format: "${tripId}|${date}". Emits available seats for that date,
/// or null when the trip has no capacity limit or no booking exists yet.
final availableSeatsForDateProvider =
    StreamProvider.autoDispose.family<int?, String>(
  (ref, tripDateKey) {
    final sep = tripDateKey.indexOf('|');
    if (sep < 0) return Stream.value(null);
    final tripId = tripDateKey.substring(0, sep);
    final date = tripDateKey.substring(sep + 1);
    return ref
        .watch(bookingRepositoryProvider)
        .watchAvailableSeatsForDate(tripId, date);
  },
);
