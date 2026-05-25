import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/contribution/user_reward_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
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


  Future<void> createBooking(BookingModel booking) async {
    // For private trips, ensure no day in the new booking's range overlaps
    // with an existing active booking.
    final tripDoc = await _trips.doc(booking.tripId).get();
    if (tripDoc.exists) {
      final tripData = tripDoc.data() as Map<String, dynamic>?;
      if ((tripData?['tripType'] as String?) == 'private') {
        final newStart = DateTime.tryParse(booking.date);
        final newDuration = booking.tripDurationDays ?? 1;
        if (newStart != null) {
          final newDates = <String>{
            for (int i = 0; i < newDuration; i++)
              fmtDate(newStart.add(Duration(days: i))),
          };
          final existing = await _bookings
              .where('tripId', isEqualTo: booking.tripId)
              .where('status', whereIn: ['pending', 'approved']).get();
          for (final doc in existing.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final dateStr = data['date'] as String? ?? '';
            final duration = (data['tripDurationDays'] as int?) ?? 1;
            final start = DateTime.tryParse(dateStr);
            if (start == null) continue;
            for (int i = 0; i < duration; i++) {
              if (newDates.contains(fmtDate(start.add(Duration(days: i))))) {
                throw Exception('tripDayAlreadyBookedError');
              }
            }
          }
        }
      }
    }

    final bookingRef = _bookings.doc(booking.bookingId);
    // Notification ref shared by both paths below.
    final notifRef = _firestore
        .collection('users')
        .doc(booking.tutorId)
        .collection('notifications')
        .doc('${booking.bookingId}_booking_new');
    const notifPayload = {
      'type': 'booking_new',
      'title': {'ar': '', 'en': ''},
      'body': {'ar': '', 'en': ''},
      'isRead': false,
    };

    if (booking.rewardId != null) {
      final rewardRef = _users
          .doc(booking.touristId)
          .collection('rewards')
          .doc(booking.rewardId);
      // Booking + reward deduction + tutor notification in a single transaction.
      await _firestore.runTransaction((transaction) async {
        final rewardSnapshot = await transaction.get(rewardRef);
        final rewardData = rewardSnapshot.data();
        final isUsed = rewardData?['isUsed'] as bool? ?? true;
        if (!rewardSnapshot.exists || isUsed) {
          throw Exception('rewardUnavailable');
        }
        transaction.set(bookingRef, booking.toMap());
        transaction.update(rewardRef, {
          'isUsed': true,
          'usedAt': FieldValue.serverTimestamp(),
          'bookingId': booking.bookingId,
        });
        transaction.set(notifRef, {
          ...notifPayload,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } else {
      // Booking + tutor notification in an atomic batch.
      final batch = _firestore.batch();
      batch.set(bookingRef, booking.toMap());
      batch.set(notifRef, {
        ...notifPayload,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    }
  }

  Stream<List<BookingModel>> fetchUserBookings(String userId, UserRole role) {
    final String field =
        (role == UserRole.tutor) ? 'tutorId' : 'touristId';
    return _bookings
        .where(field, isEqualTo: userId)
        .limit(100)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) =>
              BookingModel.fromMap(doc.data() as Map<String, dynamic>))
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
        .map((doc) =>
            BookingModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptBooking(String bookingId, String touristId) async {
    final notifRef = _firestore
        .collection('users')
        .doc(touristId)
        .collection('notifications')
        .doc('${bookingId}_booking_approved');
    final batch = _firestore.batch();
    batch.update(_bookings.doc(bookingId), {
      'status': BookingStatus.approved.name,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    batch.set(notifRef, {
      'type': 'booking_approved',
      'title': {'ar': '', 'en': ''},
      'body': {'ar': '', 'en': ''},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
    String touristId,
  ) async {
    final batch = _firestore.batch();
    batch.update(_bookings.doc(bookingId), {'status': status.name});

    if (status == BookingStatus.cancelled || status == BookingStatus.rejected) {
      final bookingSnap = await _bookings.doc(bookingId).get();
      if (bookingSnap.exists) {
        final rewardId =
            (bookingSnap.data() as Map<String, dynamic>?)?['rewardId']
                as String?;
        if (rewardId != null && rewardId.isNotEmpty) {
          batch.update(
            _users.doc(touristId).collection('rewards').doc(rewardId),
            {'isUsed': false, 'usedAt': null, 'bookingId': null},
          );
        }
      }
    }

    // Add the status-change notification to the same batch for atomicity.
    if (status == BookingStatus.cancelled || status == BookingStatus.rejected) {
      final notifType = status == BookingStatus.rejected
          ? 'booking_rejected'
          : 'booking_cancelled';
      final notifRef = _firestore
          .collection('users')
          .doc(touristId)
          .collection('notifications')
          .doc('${bookingId}_$notifType');
      batch.set(notifRef, {
        'type': notifType,
        'title': {'ar': '', 'en': ''},
        'body': {'ar': '', 'en': ''},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
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
}

final unusedRewardsProvider =
    StreamProvider.autoDispose.family<List<UserRewardModel>, String>(
  (ref, userId) {
    return ref.watch(bookingRepositoryProvider).watchUnusedRewards(userId);
  },
);
