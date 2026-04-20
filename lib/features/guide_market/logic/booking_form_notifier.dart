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
  final String? selectedTime;

  const BookingFormState({
    this.adults = 1,
    this.children = 0,
    this.selectedDate,
    this.selectedTime,
  });

  bool get isComplete => selectedDate != null && selectedTime != null;

  BookingFormState copyWith({
    int? adults,
    int? children,
    DateTime? selectedDate,
    String? selectedTime,
  }) {
    return BookingFormState(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
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

  void selectTime(String time) => state = state.copyWith(selectedTime: time);
}

final bookingFormProvider =
    AutoDisposeNotifierProvider<BookingFormNotifier, BookingFormState>(
  BookingFormNotifier.new,
);