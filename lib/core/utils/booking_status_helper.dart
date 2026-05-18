import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

/// Returns the correct role-differentiated status label for a booking.
/// [isGuide] — true when the viewer is a Guide (tutor), false for Tourist.
String bookingStatusLabel({
  required BookingStatus status,
  required bool isGuide,
  required AppLocalizations l10n,
}) {
  switch (status) {
    case BookingStatus.pending:
      return isGuide ? l10n.bookingPendingForGuide : l10n.bookingPendingForTourist;
    case BookingStatus.approved:
      return l10n.bookingApproved;
    case BookingStatus.rejected:
      return isGuide ? l10n.bookingRejectedByGuide : l10n.bookingRejectedForTourist;
    case BookingStatus.cancelled:
      return isGuide ? l10n.bookingCancelledByTourist : l10n.bookingCancelledByMe;
    case BookingStatus.completed:
      return l10n.bookingCompleted;
  }
}
