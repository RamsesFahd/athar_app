import 'package:athar_app/core/utils/currency_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/utils/booking_schedule_helper.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/bookings/widgets/rating_stars_widget.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

/// Read-only view of a completed/pending booking.
/// Formerly booking_detail_screen.dart — renamed for clarity (Issue I).
class BookingViewScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const BookingViewScreen({super.key, required this.booking});

  @override
  ConsumerState<BookingViewScreen> createState() => _BookingViewScreenState();
}

class _BookingViewScreenState extends ConsumerState<BookingViewScreen> {
  bool _isCompleting = false;

  Color _statusColor(BookingStatus status, ThemeData theme) {
    switch (status) {
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.completed:
        return theme.colorScheme.primary;
      case BookingStatus.pending:
        return Colors.amber.shade700;
    }
  }

  String _statusMessage(
      BookingStatus status, bool isGuide, AppLocalizations l10n) {
    switch (status) {
      case BookingStatus.pending:
        return isGuide
            ? l10n.bookingViewPendingGuide
            : l10n.bookingViewPendingTourist;
      case BookingStatus.approved:
        return isGuide
            ? l10n.bookingViewApprovedGuide
            : l10n.bookingViewApprovedTourist;
      case BookingStatus.rejected:
        return isGuide
            ? l10n.bookingViewRejectedGuide
            : l10n.bookingViewRejectedTourist;
      case BookingStatus.cancelled:
        return isGuide
            ? l10n.bookingViewCancelledGuide
            : l10n.bookingViewCancelledTourist;
      case BookingStatus.completed:
        return l10n.bookingViewCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.booking_details),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.booking.bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final liveBooking =
              data != null ? BookingModel.fromMap(data) : widget.booking;
          final currentUser = ref.watch(authNotifierProvider).value;
          final isTourist = currentUser is TouristModel;
          final canComplete = !isTourist &&
              canGuideMarkBookingCompleted(liveBooking, DateTime.now());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (liveBooking.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    liveBooking.imageUrl,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 190,
                      color: colorScheme.surface,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 34,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildBookingOverviewCard(
                  theme, isAr, l10n, ref, isTourist, liveBooking),
              const SizedBox(height: 24),
              if (!isTourist && canComplete)
                SizedBox(
                  width: double.infinity,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: ElevatedButton.icon(
                      onPressed: _isCompleting
                          ? null
                          : () => _completeBooking(liveBooking),
                      icon: _isCompleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(l10n.bookingCompleted),
                    ),
                  ),
                ),
              if (isTourist && liveBooking.status == BookingStatus.completed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RatingStarsWidget(
                    bookingId: liveBooking.bookingId,
                    touristId: liveBooking.touristId,
                    tutorId: liveBooking.tutorId,
                    tripId: liveBooking.tripId,
                  ),
                ),
              if (isTourist && liveBooking.status == BookingStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.bookingCancelTitle),
                            content: Text(l10n.cancelBookingConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(l10n.bookingCancelNo),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  l10n.bookingCancelYes,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          // Issue H fix: delegate to BookingNotifier instead of
                          // calling the repository directly from the screen.
                          await ref
                              .read(bookingNotifierProvider.notifier)
                              .cancelBooking(liveBooking.bookingId);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon:
                          const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: Text(
                        l10n.bookingCancelButton,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _completeBooking(BookingModel booking) async {
    setState(() => _isCompleting = true);
    try {
      await ref
          .read(marketplaceRepositoryProvider)
          .markBookingCompleted(booking.bookingId);
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  Widget _buildBookingOverviewCard(
    ThemeData theme,
    bool isAr,
    AppLocalizations l10n,
    WidgetRef ref,
    bool isTourist,
    BookingModel booking,
  ) {
    final isGuide = !isTourist;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final statusColor = _statusColor(booking.status, theme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.tripTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (booking.tripCity.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.tripCity,
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _statusMessage(booking.status, isGuide, l10n),
              style: textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.bookingTripDetailsTitle,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _modernInfoRow(theme, Icons.calendar_today, l10n.date, booking.date),
          _modernInfoRow(
            theme,
            Icons.access_time,
            l10n.time,
            _localizedTimeSlot(booking.timeSlot, isAr, l10n),
          ),
          _modernInfoRow(
            theme,
            Icons.people_outline,
            l10n.people_count,
            l10n.bookingPeopleSummary(
                booking.adultsCount, booking.childrenCount),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.bookingPriceSummaryTitle,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.total_price,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                CurrencyFormatter.format(
                  booking.totalPrice,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (booking.status == BookingStatus.approved ||
              booking.status == BookingStatus.completed) ...[
            const SizedBox(height: 18),
            Text(
              isGuide ? l10n.bookingTouristLabel : l10n.bookingGuideLabel,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(isGuide ? booking.touristId : booking.tutorId)
                  .snapshots(),
              builder: (context, snap) {
                final data = snap.data?.data() as Map<String, dynamic>?;
                final name = data?['fullName'] as String? ?? '';
                final phone = data?['phoneNumber'] as String? ?? '';
                final email = data?['email'] as String? ?? '';
                return _contactRows(
                  theme: theme,
                  l10n: l10n,
                  isGuide: isGuide,
                  name: name.isNotEmpty ? name : null,
                  phone: phone.isNotEmpty ? phone : null,
                  email: email.isNotEmpty ? email : null,
                );
              },
            ),
          ],
          if (booking.status == BookingStatus.rejected) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l10n.bookingRejectedExploreMore,
                style: textTheme.bodySmall,
              ),
            ),
          ],
          if (isGuide && booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => ref
                        .read(marketplaceRepositoryProvider)
                        .acceptBooking(booking.bookingId, booking.touristId),
                    child: Text(l10n.accept_booking),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => ref
                        .read(marketplaceRepositoryProvider)
                        .updateBookingStatus(
                          booking.bookingId,
                          BookingStatus.rejected,
                          booking.touristId,
                        ),
                    child: Text(
                      l10n.reject_booking,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactRows({
    required ThemeData theme,
    required AppLocalizations l10n,
    required bool isGuide,
    required String? name,
    required String? phone,
    required String? email,
  }) {
    final personLabel =
        isGuide ? l10n.bookingTouristLabel : l10n.bookingGuideLabel;
    return Column(
      children: [
        _modernInfoRow(
          theme,
          Icons.person_outline,
          personLabel,
          name ?? l10n.bookingAvailableSoon,
        ),
        _modernInfoRow(
          theme,
          Icons.phone_outlined,
          l10n.bookingPhoneLabel,
          phone ?? l10n.bookingShownAfterConfirmation,
        ),
        _modernInfoRow(
          theme,
          Icons.email_outlined,
          l10n.emailLabel,
          email ?? l10n.bookingShownAfterConfirmation,
        ),
      ],
    );
  }

  Widget _modernInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizedTimeSlot(String timeSlot, bool isAr, AppLocalizations l10n) {
    if (!isAr) return timeSlot;
    return timeSlot
        .replaceAll(RegExp(r'AM', caseSensitive: false), l10n.timeAmMarker)
        .replaceAll(RegExp(r'PM', caseSensitive: false), l10n.timePmMarker);
  }
}
