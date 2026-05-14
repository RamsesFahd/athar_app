import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';

TripModel _makeTrip({
  required String id,
  required DateTime startDate,
  required DateTime endDate,
}) =>
    TripModel(
      id: id,
      titleAr: '',
      titleEn: '',
      cityAr: '',
      cityEn: '',
      guide: '',
      company: '',
      adultPrice: 0.0,
      childPrice: 0.0,
      imageUrl: '',
      descriptionAr: '',
      descriptionEn: '',
      license: '',
      shortDescriptionAr: '',
      shortDescriptionEn: '',
      startDate: startDate,
      endDate: endDate,
    );

void main() {
  group('TripModel - Duration Calculations', () {
    test('UT-29: durationDays returns 1 for a single-day trip', () {
      final trip = _makeTrip(
        id: 'test-trip-1',
        startDate: DateTime(2025, 7, 10),
        endDate: DateTime(2025, 7, 10),
      );

      expect(trip.durationDays, equals(1));
    });

    test('UT-30: durationDays returns 4 for a four-day trip', () {
      final trip = _makeTrip(
        id: 'test-trip-2',
        startDate: DateTime(2025, 7, 10),
        endDate: DateTime(2025, 7, 13),
      );

      expect(trip.durationDays, equals(4));
    });

    test('UT-31: isMultiDay returns false for single-day trip', () {
      final trip = _makeTrip(
        id: 'test-trip-3',
        startDate: DateTime(2025, 7, 10),
        endDate: DateTime(2025, 7, 10),
      );

      expect(trip.isMultiDay, isFalse);
    });

    test('UT-32: isMultiDay returns true for multi-day trip', () {
      final trip = _makeTrip(
        id: 'test-trip-4',
        startDate: DateTime(2025, 7, 10),
        endDate: DateTime(2025, 7, 13),
      );

      expect(trip.isMultiDay, isTrue);
    });
  });
}
