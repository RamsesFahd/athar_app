import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/features/notifications/logic/notifications_repository.dart';
part 'marketplace_repository.g.dart';

@riverpod
MarketplaceRepository marketplaceRepository(Ref ref) {
  return MarketplaceRepository();
}

class MarketplaceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // مجموعات البيانات في Firestore
  CollectionReference get _trips => _firestore.collection('trips');
  CollectionReference get _bookings => _firestore.collection('bookings');
  CollectionReference get _users => _firestore.collection('users');

  // 1. جلب كل الرحلات المتاحة
  Stream<List<TripModel>> fetchAllTrips() {
    return _trips
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. جلب المرشدين (Tutors) الموثقين فقط [cite: 139]
  Future<List<TutorModel>> fetchAvailableTutors() async {
    final query = await _users
        .where('role', isEqualTo: UserRole.tutor.name)
        // يمكنك إضافة فلتر التوثيق هنا مستقبلاً
        .get();
    return query.docs
        .map((doc) => TutorModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // 3. حفظ الحجز الجديد في Firestore
  Future<void> createBooking(BookingModel booking) async {
    // Guard: for private trips, ensure this specific day is not already booked.
    final tripDoc = await _trips.doc(booking.tripId).get();
    if (tripDoc.exists) {
      final tripData = tripDoc.data() as Map<String, dynamic>?;
      if ((tripData?['tripType'] as String?) == 'private') {
        final existing = await _bookings
            .where('tripId', isEqualTo: booking.tripId)
            .where('date', isEqualTo: booking.date)
            .where('status', whereIn: ['pending', 'approved'])
            .get();
        if (existing.docs.isNotEmpty) {
          throw Exception('tripDayAlreadyBookedError');
        }
      }
    }

    await _bookings.doc(booking.bookingId).set(booking.toMap());
    // Deterministic ID prevents duplicate if a Cloud Function also fires this.
    await NotificationsRepository().addNotification(
      userId: booking.tutorId,
      type: 'booking_new',
      notificationId: '${booking.bookingId}_booking_new',
    );
  }

  /// Returns the set of dates (yyyy-MM-dd) that have an active (pending or
  /// approved) booking for the given trip. Used to block days in the date
  /// picker and to determine if a private trip is fully booked.
  Future<Set<String>> fetchBookedDates(String tripId) async {
    final snap = await _bookings
        .where('tripId', isEqualTo: tripId)
        .where('status', whereIn: ['pending', 'approved'])
        .get();
    return snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)['date'] as String? ?? '')
        .where((d) => d.isNotEmpty)
        .toSet();
  }

  // 5. تقديم رحلة جديدة من قِبل المرشد (تُحفظ بحالة pending حتى يوافق الأدمن)
  Future<void> submitTrip(TripModel trip) async {
    await _trips.doc(trip.id).set(trip.toMap());
    // Notify all admins that a new trip is pending review.
    final adminSnap = await _users
        .where('role', isEqualTo: UserRole.admin.name)
        .get();
    final repo = NotificationsRepository();
    for (final doc in adminSnap.docs) {
      await repo.addNotification(
        userId: doc.id,
        type: 'trip_submitted',
      );
    }
  }

  // 6. جلب رحلات مرشد معين
  Stream<List<TripModel>> fetchTutorTrips(String tutorId) {
    return _trips
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // 4. جلب حجوزات مستخدم معين (سائح أو مرشد) بناءً على دوره [cite: 111]
  Stream<List<BookingModel>> fetchUserBookings(String userId, UserRole role) {
    String field = (role == UserRole.tutor) ? 'tutorId' : 'touristId';
    return _bookings
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) =>
                  BookingModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // 7. تحديث حالة الحجز (قبول / رفض / إكمال)
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
    String touristId,
  ) async {
    await _bookings.doc(bookingId).update({'status': status.name});

    if (status == BookingStatus.cancelled ||
        status == BookingStatus.rejected) {
      await NotificationsRepository().addNotification(
        userId: touristId,
        type: 'booking_cancelled',
      );
    }
  }

  /// 7b. قبول الحجز — معلومات التواصل تُقرأ live من user document
  Future<void> acceptBooking(
    String bookingId,
    String touristId,
  ) async {
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.approved.name,
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // Deterministic ID prevents duplicate if a Cloud Function also fires this.
    await NotificationsRepository().addNotification(
      userId: touristId,
      type: 'booking_approved',
      notificationId: '${bookingId}_booking_approved',
    );
  }

  // 8. حذف رحلة
  Future<void> deleteTrip(String tripId) async {
    await _trips.doc(tripId).delete();
  }

  // 9. تحديث رحلة موجودة
  Future<void> updateTrip(TripModel trip) async {
    await _trips.doc(trip.id).update(trip.toMap());
  }

  // 10a. جلب بيانات مرشد بمعرّفه — لعرض معلومات التواصل في الحجوزات القديمة
  Future<TutorModel?> fetchTutorById(String tutorId) async {
    final doc = await _users.doc(tutorId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;
    try {
      return TutorModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Future<TripModel?> fetchTripById(String tripId) async {
    final doc = await _trips.doc(tripId).get();
    if (!doc.exists) return null;
    return TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // 10. جلب حجوزات مستخدم مرة واحدة (Future، لا Stream) — يُستخدم لفحوصات الأمان
  Future<List<BookingModel>> fetchUserBookingsOnce(
      String userId, UserRole role) async {
    final String field =
        (role == UserRole.tutor) ? 'tutorId' : 'touristId';
    final snapshot =
        await _bookings.where(field, isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) =>
            BookingModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

/// Reactive stream of all approved trips. Using a [StreamProvider] here
/// (instead of calling the repository directly inside a [StreamBuilder])
/// ensures the stream is re-created whenever the underlying provider
/// rebuilds (e.g. after an auth change) and is shared across all watchers.
final allTripsStreamProvider =
    StreamProvider.autoDispose<List<TripModel>>((ref) {
  return ref.watch(marketplaceRepositoryProvider).fetchAllTrips();
});

/// The set of booked dates (yyyy-MM-dd) for a given trip, considering only
/// active (pending/approved) bookings. Consumed by the date picker (to grey
/// out taken days) and by the "fully booked" check for private trips.
final bookedDatesForTripProvider =
    FutureProvider.autoDispose.family<Set<String>, String>((ref, tripId) {
  return ref.read(marketplaceRepositoryProvider).fetchBookedDates(tripId);
});
