import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';

TripModel _makeTrip() {
  return TripModel(
    id: 'trip-1',
    titleAr: 'رحلة جدة',
    titleEn: 'Jeddah Trip',
    cityAr: 'جدة',
    cityEn: 'Jeddah',
    guide: '',
    company: '',
    adultPrice: 100.0,
    childPrice: 50.0,
    imageUrl: 'image.png',
    descriptionAr: '',
    descriptionEn: '',
    license: '',
    shortDescriptionAr: '',
    shortDescriptionEn: '',
    startDate: DateTime(2025, 7, 10),
    endDate: DateTime(2025, 7, 10),
    tutorId: 'tutor-1',
  );
}

void main() {
  group('BookingNotifier - Booking Flow Logic', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('UT-01: initial booking state is null', () {
      final booking = container.read(bookingNotifierProvider);

      expect(booking, isNull);
    });

    test('UT-02: startBooking creates booking with trip data', () {
      final notifier = container.read(bookingNotifierProvider.notifier);
      final trip = _makeTrip();

      notifier.startBooking(trip);

      final booking = container.read(bookingNotifierProvider);

      expect(booking, isNotNull);
      expect(booking!.tripId, equals('trip-1'));
      expect(booking.tutorId, equals('tutor-1'));
      expect(booking.adultsCount, equals(1));
      expect(booking.childrenCount, equals(0));
      expect(booking.adultPrice, equals(100.0));
      expect(booking.childPrice, equals(50.0));
    });

    test('UT-03: updateDetails updates date, time, counts, and total price', () {
      final notifier = container.read(bookingNotifierProvider.notifier);
      notifier.startBooking(_makeTrip());

      notifier.updateDetails(
        date: '2025-07-10',
        time: '10:00 AM',
        adults: 2,
        children: 1,
        adultPrice: 100.0,
        childPrice: 50.0,
        totalPrice: 250.0,
      );

      final booking = container.read(bookingNotifierProvider);

      expect(booking!.date, equals('2025-07-10'));
      expect(booking.timeSlot, equals('10:00 AM'));
      expect(booking.adultsCount, equals(2));
      expect(booking.childrenCount, equals(1));
      expect(booking.totalPrice, equals(250.0));
    });

    test('UT-04: updateDetails does nothing when state is null', () {
      final notifier = container.read(bookingNotifierProvider.notifier);

      notifier.updateDetails(
        date: '2025-07-10',
        time: '10:00 AM',
        adults: 2,
        children: 1,
        adultPrice: 100.0,
        childPrice: 50.0,
        totalPrice: 250.0,
      );

      final booking = container.read(bookingNotifierProvider);

      expect(booking, isNull);
    });

    test('UT-05: selectTutor updates tutorId when booking exists', () {
      final notifier = container.read(bookingNotifierProvider.notifier);
      notifier.startBooking(_makeTrip());

      notifier.selectTutor('tutor-2', 'Guide Name');

      final booking = container.read(bookingNotifierProvider);

      expect(booking!.tutorId, equals('tutor-2'));
    });

    test('UT-06: selectTutor does nothing when state is null', () {
      final notifier = container.read(bookingNotifierProvider.notifier);

      notifier.selectTutor('tutor-2', 'Guide Name');

      final booking = container.read(bookingNotifierProvider);

      expect(booking, isNull);
    });
  });
}