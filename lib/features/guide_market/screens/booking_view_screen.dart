import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

/// Read-only view of a completed/pending booking.
/// Formerly booking_detail_screen.dart — renamed for clarity (Issue I).
class BookingViewScreen extends ConsumerWidget {
  final BookingModel booking;

  const BookingViewScreen({super.key, required this.booking});

  Color _statusColor(BookingStatus status, ThemeData theme) {
  switch (status) {
    case BookingStatus.accepted:
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

String _statusLabel(BookingStatus status, bool isAr) {
  switch (status) {
    case BookingStatus.accepted:
      return isAr ? 'مقبول' : 'Accepted';
    case BookingStatus.rejected:
      return isAr ? 'مرفوض' : 'Rejected';
    case BookingStatus.cancelled:
      return isAr ? 'ملغي' : 'Cancelled';
    case BookingStatus.completed:
      return isAr ? 'مكتمل' : 'Completed';
    case BookingStatus.pending:
      return isAr ? 'قيد المراجعة' : 'Pending';
  }
}

String _statusMessage(BookingStatus status, bool isAr) {
  switch (status) {
    case BookingStatus.accepted:
      return isAr
          ? 'تم قبول الحجز. يمكنك الآن مراجعة التفاصيل والمتابعة مع مزود الرحلة.'
          : 'Your booking has been accepted. You can now review the details and follow up with the trip provider.';
    case BookingStatus.rejected:
      return isAr
          ? 'نعتذر، تم رفض هذا الحجز. يمكنك تجربة موعد آخر أو رحلة مختلفة.'
          : 'Sorry, this booking was rejected. You can try another date or a different trip.';
    case BookingStatus.cancelled:
      return isAr
          ? 'تم إلغاء هذا الحجز.'
          : 'This booking has been cancelled.';
    case BookingStatus.completed:
      return isAr
          ? 'تمت هذه الرحلة بنجاح.'
          : 'This trip has been completed successfully.';
    case BookingStatus.pending:
      return isAr
          ? 'طلبك قيد المراجعة حاليًا. سيتم إشعارك عند تحديث الحالة.'
          : 'Your booking is currently under review. You will be notified once the status changes.';
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(authNotifierProvider).value;
    final isTourist = currentUser is TouristModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'تفاصيل الحجز' : 'Booking Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (booking.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                booking.imageUrl,
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

          _buildBookingOverviewCard(theme, isAr, l10n, ref),

          const SizedBox(height: 24),

          if (isTourist && booking.status == BookingStatus.pending)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(isAr ? 'إلغاء الحجز؟' : 'Cancel Booking?'),
                      content: Text(
                        isAr
                            ? 'هل أنت متأكد أنك تريد إلغاء هذا الحجز؟'
                            : 'Are you sure you want to cancel this booking?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(isAr ? 'لا' : 'No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            isAr ? 'نعم، إلغاء' : 'Yes, Cancel',
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
                        .cancelBooking(booking.bookingId);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: Text(
                  isAr ? 'إلغاء الحجز' : 'Cancel Booking',
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
        ],
      ),
    );
  }

  Widget _buildBookingOverviewCard(
    ThemeData theme,
    bool isAr,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
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
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  _statusLabel(booking.status, isAr),
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
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
              _statusMessage(booking.status, isAr),
              style: textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isAr ? 'تفاصيل الرحلة' : 'Trip Details',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          _modernInfoRow(theme, Icons.calendar_today, l10n.date, booking.date),
          _modernInfoRow(
            theme,
            Icons.access_time,
            l10n.time,
            _localizedTimeSlot(booking.timeSlot, isAr),
          ),
          _modernInfoRow(
            theme,
            Icons.people_outline,
            l10n.people_count,
            isAr
                ? '${booking.adultsCount} بالغ، ${booking.childrenCount} طفل'
                : '${booking.adultsCount} Adults, ${booking.childrenCount} Children',
          ),

          const SizedBox(height: 18),

          Text(
            isAr ? 'ملخص السعر' : 'Price Summary',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          _modernPriceRow(
            theme,
            isAr
                ? '${booking.adultsCount} بالغ × ${booking.adultPrice.toInt()} ر.س'
                : '${booking.adultsCount} Adult × ${booking.adultPrice.toInt()} SAR',
            '${(booking.adultsCount * booking.adultPrice).toInt()} ${l10n.currency}',
          ),

          if (booking.childrenCount > 0)
            _modernPriceRow(
              theme,
              booking.childPrice == 0
                  ? (isAr
                      ? '${booking.childrenCount} طفل (مجانًا)'
                      : '${booking.childrenCount} Child (Free)')
                  : (isAr
                      ? '${booking.childrenCount} طفل × ${booking.childPrice.toInt()} ر.س'
                      : '${booking.childrenCount} Child × ${booking.childPrice.toInt()} SAR'),
              booking.childPrice == 0
                  ? (isAr ? 'مجانًا' : 'Free')
                  : '${(booking.childrenCount * booking.childPrice).toInt()} ${l10n.currency}',
            ),

          const SizedBox(height: 10),

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
                Text(
                  '${booking.totalPrice.toInt()} ${l10n.currency}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          if (booking.status == BookingStatus.accepted) ...[
            const SizedBox(height: 18),
            Text(
              isAr ? 'معلومات التواصل' : 'Contact Information',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            // Old bookings accepted before tutorName/tutorPhone were stored:
            // fall back to a live Firestore fetch using tutorId.
            if (booking.tutorName != null || booking.tutorPhone != null)
              _contactRows(
                theme: theme,
                isAr: isAr,
                name: booking.tutorName,
                phone: booking.tutorPhone,
              )
            else
              FutureBuilder<TutorModel?>(
                future: ref
                    .read(marketplaceRepositoryProvider)
                    .fetchTutorById(booking.tutorId),
                builder: (context, snap) {
                  final tutor = snap.data;
                  return _contactRows(
                    theme: theme,
                    isAr: isAr,
                    name: tutor?.fullName,
                    phone: tutor?.phoneNumber,
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
                isAr
                    ? 'يمكنك العودة واستعراض رحلات أخرى أو اختيار موعد مختلف.'
                    : 'You can go back and explore other trips or choose a different date.',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactRows({
    required ThemeData theme,
    required bool isAr,
    required String? name,
    required String? phone,
  }) {
    return Column(
      children: [
        _modernInfoRow(
          theme,
          Icons.person_outline,
          isAr ? 'المرشد' : 'Guide',
          (name != null && name.isNotEmpty)
              ? name
              : (isAr ? 'سيظهر لاحقًا' : 'Available soon'),
        ),
        _modernInfoRow(
          theme,
          Icons.phone_outlined,
          isAr ? 'رقم التواصل' : 'Phone',
          (phone != null && phone.isNotEmpty)
              ? phone
              : (isAr ? 'سيظهر بعد التأكيد' : 'Shown after confirmation'),
        ),
        _modernInfoRow(
          theme,
          Icons.place_outlined,
          isAr ? 'نقطة التجمع' : 'Meeting Point',
          isAr ? 'سيتم تحديدها لاحقًا' : 'To be shared later',
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

  Widget _modernPriceRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _localizedTimeSlot(String timeSlot, bool isAr) {
    if (!isAr) return timeSlot;
    return timeSlot
        .replaceAll(RegExp(r'AM', caseSensitive: false), 'ص')
        .replaceAll(RegExp(r'PM', caseSensitive: false), 'م');
  }
}