import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the transient form state for the booking-details step:
/// adult/child counts and the chosen date/time slot. This lives in
/// a Notifier so screens never use setState for business-relevant state.
///
/// autoDispose ensures the form resets automatically when the booking
/// flow is exited (e.g. user presses back).
class BookingFormState {
  final int adults;
  final int children;
  final DateTime? selectedDate;

  const BookingFormState({
    this.adults = 1,
    this.children = 0,
    this.selectedDate,
  });

  bool get isComplete => selectedDate != null;

  BookingFormState copyWith({
    int? adults,
    int? children,
    DateTime? selectedDate,
  }) {
    return BookingFormState(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class BookingFormNotifier extends AutoDisposeNotifier<BookingFormState> {
  @override
  BookingFormState build() => const BookingFormState();

  void incrementAdults() => state = state.copyWith(adults: state.adults + 1);

  void decrementAdults() {
    if (state.adults > 1) state = state.copyWith(adults: state.adults - 1);
  }

  void incrementChildren() =>
      state = state.copyWith(children: state.children + 1);

  void decrementChildren() {
    if (state.children > 0) {
      state = state.copyWith(children: state.children - 1);
    }
  }

  void selectDate(DateTime date) => state = state.copyWith(selectedDate: date);

}

final bookingFormProvider =
    AutoDisposeNotifierProvider<BookingFormNotifier, BookingFormState>(
  BookingFormNotifier.new,
);