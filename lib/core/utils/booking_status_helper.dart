import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Returns the status chip/badge color for a booking, respecting the app's
/// high-contrast setting baked into [theme] via [AtharThemeExtension].
Color bookingStatusColor(BookingStatus status, ThemeData theme) {
  if (theme.isHighContrast &&
      (status == BookingStatus.pending ||
          status == BookingStatus.approved ||
          status == BookingStatus.completed)) {
    return theme.colorScheme.primary;
  }
  switch (status) {
    case BookingStatus.approved:
      return Colors.green;
    case BookingStatus.rejected:
      return Colors.red;
    case BookingStatus.cancelled:
      return theme.colorScheme.onSurfaceVariant;
    case BookingStatus.completed:
      return theme.colorScheme.primary;
    case BookingStatus.pending:
      return Colors.amber.shade700;
    case BookingStatus.expired:
      return Colors.grey.shade500;
  }
}

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
    case BookingStatus.expired:
      return l10n.bookingExpired;
  }
}
