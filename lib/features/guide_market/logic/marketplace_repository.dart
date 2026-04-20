import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';

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

  // 3. حفظ الحجز الجديد في Firestore [cite: 110]
  Future<void> createBooking(BookingModel booking) async {
    await _bookings.doc(booking.bookingId).set(booking.toMap());
  }

  // 5. تقديم رحلة جديدة من قِبل المرشد (تُحفظ بحالة pending حتى يوافق الأدمن)
  Future<void> submitTrip(TripModel trip) async {
    await _trips.doc(trip.id).set(trip.toMap());
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
      String bookingId, BookingStatus status) async {
    await _bookings.doc(bookingId).update({'status': status.name});
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
