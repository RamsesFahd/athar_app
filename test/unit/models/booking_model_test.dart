import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';

void main() {
  group('BookingModel', () {
    final baseCreatedAt = DateTime(2024, 6, 1, 10, 0, 0);

    BookingModel makeBooking() => BookingModel(
          bookingId: 'b1',
          touristId: 't1',
          tutorId: 'tu1',
          tripId: 'tr1',
          tripTitle: 'Test Trip',
          tripCity: 'Riyadh',
          date: '2024-06-15',
          timeSlot: '10:00 AM',
          adultsCount: 2,
          childrenCount: 1,
          adultPrice: 100.0,
          childPrice: 50.0,
          totalPrice: 250.0,
          status: BookingStatus.pending,
          createdAt: baseCreatedAt,
          imageUrl: 'https://example.com/img.jpg',
          tutorPhone: '+966500000000',
          tutorName: 'Ali Ahmed',
        );

    test('UT-33: toMap/fromMap round-trip — all fields survive serialization',
        () {
      // Arrange
      final original = makeBooking();

      // Act
      final map = original.toMap();
      final restored = BookingModel.fromMap(map);

      // Assert
      expect(restored.bookingId, original.bookingId);
      expect(restored.touristId, original.touristId);
      expect(restored.tutorId, original.tutorId);
      expect(restored.tripId, original.tripId);
      expect(restored.tripTitle, original.tripTitle);
      expect(restored.tripCity, original.tripCity);
      expect(restored.date, original.date);
      expect(restored.timeSlot, original.timeSlot);
      expect(restored.adultsCount, original.adultsCount);
      expect(restored.childrenCount, original.childrenCount);
      expect(restored.adultPrice, original.adultPrice);
      expect(restored.childPrice, original.childPrice);
      expect(restored.totalPrice, original.totalPrice);
      expect(restored.status, original.status);
      expect(restored.createdAt, original.createdAt);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.tutorPhone, original.tutorPhone);
      expect(restored.tutorName, original.tutorName);
    });

    test('UT-34: fromMap with missing optional field — tutorPhone/tutorName are null',
        () {
      // Arrange — map without tutorPhone and tutorName
      final map = <String, dynamic>{
        'bookingId': 'b2',
        'touristId': 't2',
        'tutorId': 'tu2',
        'tripId': 'tr2',
        'tripTitle': 'Trip 2',
        'tripCity': 'Jeddah',
        'date': '2024-07-01',
        'timeSlot': '2:00 PM',
        'adultsCount': 1,
        'childrenCount': 0,
        'adultPrice': 80.0,
        'childPrice': 0.0,
        'totalPrice': 80.0,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime(2024, 7, 1)),
        'imageUrl': 'https://example.com/img2.jpg',
        // tutorPhone and tutorName intentionally omitted
      };

      // Act
      final booking = BookingModel.fromMap(map);

      // Assert
      expect(booking.tutorPhone, isNull);
      expect(booking.tutorName, isNull);
    });

    test('UT-35: copyWith partial update — only status changes', () {
      // Arrange
      final original = makeBooking();

      // Act
      final updated = original.copyWith(status: BookingStatus.accepted);

      // Assert — status changed
      expect(updated.status, BookingStatus.accepted);
      // Assert — all other fields unchanged
      expect(updated.bookingId, original.bookingId);
      expect(updated.touristId, original.touristId);
      expect(updated.tutorId, original.tutorId);
      expect(updated.tripId, original.tripId);
      expect(updated.tripTitle, original.tripTitle);
      expect(updated.tripCity, original.tripCity);
      expect(updated.date, original.date);
      expect(updated.timeSlot, original.timeSlot);
      expect(updated.adultsCount, original.adultsCount);
      expect(updated.childrenCount, original.childrenCount);
      expect(updated.adultPrice, original.adultPrice);
      expect(updated.childPrice, original.childPrice);
      expect(updated.totalPrice, original.totalPrice);
      expect(updated.createdAt, original.createdAt);
      expect(updated.imageUrl, original.imageUrl);
      expect(updated.tutorPhone, original.tutorPhone);
      expect(updated.tutorName, original.tutorName);
    });
  });
}
