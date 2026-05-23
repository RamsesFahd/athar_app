import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart'; 
import 'marketplace_repository.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';

part 'booking_notifier.g.dart';

@riverpod
class BookingNotifier extends _$BookingNotifier {
  @override
  BookingModel? build() {
    ref.keepAlive(); // prevent auto-disposal across multi-screen booking flow
    return null; // initial state is null, meaning no booking in progress
  }

  // Step 0: Start a new booking with basic trip info
  void startBooking(TripModel trip) {
    state = BookingModel(
      bookingId: const Uuid().v4(),
      touristId: '',
      tutorId: trip.tutorId ?? '',
      tripId: trip.id,
      tripTitle: '${trip.titleAr} - ${trip.titleEn}',
      tripCity: '${trip.cityAr} - ${trip.cityEn}',
      date: '',
      timeSlot: '',
      adultsCount: 1,
      childrenCount: 0,
      adultPrice: trip.adultPrice,
      childPrice: trip.childPrice,
      totalPrice: 0.0,
      createdAt: DateTime.now(),
      imageUrl: trip.imageUrl,
      tripDurationDays: trip.tripDurationDays,
    );
  }

  // Step 1: Update booking details (date, time, counts, prices)
  void updateDetails({
    required String date,
    required String time,
    required int adults,
    required int children,
    required double adultPrice,
    required double childPrice,
    required double totalPrice,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      date: date,
      timeSlot: time,
      adultsCount: adults,
      childrenCount: children,
      adultPrice: adultPrice,
      childPrice: childPrice,
      totalPrice: totalPrice,
    );
  }

  // Step 2: Select a tutor
  void selectTutor(String tutorId, String tutorName) {
    if (state == null) return;
    state = state!.copyWith(tutorId: tutorId);
  }

  // Step 3: Confirm the booking and submit it to the backend
  Future<void> confirmBooking() async {
    if (state == null) return;

    // Fetch the current tourist's uId from AuthNotifier
    final currentUser = await ref.read(authNotifierProvider.future);
    if (currentUser == null) throw 'User not logged in';

    final finalBooking = state!.copyWith(touristId: currentUser.uId);

    // call the repository to create the booking
    await ref.read(marketplaceRepositoryProvider).createBooking(finalBooking);

    // reset the state after successful booking
    state = null;
  }

  // Step 4 (optional): Cancel a pending booking (tourist action)
  Future<void> cancelBooking(String bookingId) async {
  final currentUser = await ref.read(authNotifierProvider.future);

  if (currentUser == null) {
    throw 'User not logged in';
  }

  await ref
      .read(marketplaceRepositoryProvider)
      .updateBookingStatus(
        bookingId,
        BookingStatus.cancelled,
        currentUser.uId,
      );
}
}
