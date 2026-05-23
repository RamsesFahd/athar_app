import 'package:athar_app/core/models/booking/booking_model.dart';

DateTime? bookingScheduledStart(BookingModel booking) {
  final bookingDate = DateTime.tryParse(booking.date);
  if (bookingDate == null) return null;

  final timeParts = _extractTimeParts(booking.timeSlot);
  if (timeParts.isEmpty) return null;

  final startTime = timeParts.first;
  return DateTime(
    bookingDate.year,
    bookingDate.month,
    bookingDate.day,
    startTime.$1,
    startTime.$2,
  );
}

DateTime? bookingScheduledEnd(BookingModel booking) {
  final bookingDate = DateTime.tryParse(booking.date);
  if (bookingDate == null) return null;

  final timeParts = _extractTimeParts(booking.timeSlot);
  if (timeParts.isEmpty) return null;

  // For multi-day trips, the end is on the last day of the booking.
  final duration = booking.tripDurationDays ?? 1;
  final lastDay = bookingDate.add(Duration(days: duration - 1));

  final endTime = timeParts.length > 1 ? timeParts.last : timeParts.first;
  var scheduledEnd = DateTime(
    lastDay.year,
    lastDay.month,
    lastDay.day,
    endTime.$1,
    endTime.$2,
  );

  final scheduledStart = bookingScheduledStart(booking);
  if (scheduledStart != null && scheduledEnd.isBefore(scheduledStart)) {
    scheduledEnd = scheduledEnd.add(const Duration(days: 1));
  }

  return scheduledEnd;
}

bool canGuideMarkBookingCompleted(BookingModel booking, DateTime now) {
  if (booking.status != BookingStatus.approved) return false;

  final scheduledEnd = bookingScheduledEnd(booking);
  if (scheduledEnd == null) return false;

  return !now.isBefore(scheduledEnd);
}

bool shouldSendGuideReminder(BookingModel booking, DateTime now) {
  if (booking.status != BookingStatus.approved) return false;

  final scheduledStart = bookingScheduledStart(booking);
  if (scheduledStart == null) return false;

  return _sameCalendarDay(scheduledStart, now);
}

List<(int, int)> _extractTimeParts(String timeSlot) {
  final matches = RegExp(r'(\d{1,2}):(\d{2})').allMatches(timeSlot);
  return matches
      .map((match) => (
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
          ))
      .toList();
}

bool _sameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
