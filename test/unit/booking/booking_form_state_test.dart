import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/features/guide_market/logic/booking_form_notifier.dart';

void main() {
  group('BookingFormNotifier - Form State Logic', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('UT-59: initial state has one adult, zero children, and is incomplete',
        () {
      final state = container.read(bookingFormProvider);

      expect(state.adults, 1);
      expect(state.children, 0);
      expect(state.selectedDate, isNull);
      expect(state.isComplete, isFalse);
    });

    test('UT-60: increment/decrement adults never goes below one', () {
      final notifier = container.read(bookingFormProvider.notifier);

      notifier.incrementAdults();
      notifier.decrementAdults();
      notifier.decrementAdults();

      final state = container.read(bookingFormProvider);

      expect(state.adults, 1);
    });

    test('UT-61: increment/decrement children never goes below zero', () {
      final notifier = container.read(bookingFormProvider.notifier);

      notifier.incrementChildren();
      notifier.decrementChildren();
      notifier.decrementChildren();

      final state = container.read(bookingFormProvider);

      expect(state.children, 0);
    });

    test('UT-62: selectDate marks the form complete', () {
      final notifier = container.read(bookingFormProvider.notifier);
      final date = DateTime(2025, 7, 10);

      notifier.selectDate(date);

      final state = container.read(bookingFormProvider);

      expect(state.selectedDate, date);
      expect(state.isComplete, isTrue);
    });
  });
}
