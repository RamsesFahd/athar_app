import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class BookingDetailScreen extends ConsumerWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  Color _statusColor(BookingStatus status, ThemeData theme) {
    switch (status) {
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
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
      case BookingStatus.completed:
        return isAr ? 'مكتمل' : 'Completed';
      case BookingStatus.pending:
        return isAr ? 'قيد المراجعة' : 'Pending';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
          // ── Trip image ────────────────────────────────────────────
          if (booking.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                booking.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),

          // ── Status badge ──────────────────────────────────────────
          Center(
            child: Chip(
              label: Text(
                _statusLabel(booking.status, isAr),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: _statusColor(booking.status, theme),
            ),
          ),
          const SizedBox(height: 16),

          // ── Trip info card ────────────────────────────────────────
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.tripTitle,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (booking.tripCity.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(booking.tripCity,
                          style: theme.textTheme.bodySmall),
                    ]),
                  ],
                  const Divider(height: 24),
                  _infoRow(theme, Icons.calendar_today, l10n.date, booking.date),
                  _infoRow(theme, Icons.access_time, l10n.time, booking.timeSlot),
                  _infoRow(
                    theme,
                    Icons.people_outline,
                    l10n.people_count,
                    isAr
                        ? '${booking.adultsCount} بالغ، ${booking.childrenCount} طفل'
                        : '${booking.adultsCount} Adults, ${booking.childrenCount} Children',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Price breakdown card ──────────────────────────────────
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.total_price,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _priceRow(
                    theme,
                    isAr
                        ? '${booking.adultsCount} بالغ × ${booking.adultPrice.toInt()} ر.س'
                        : '${booking.adultsCount} Adult × ${booking.adultPrice.toInt()} SAR',
                    '${(booking.adultsCount * booking.adultPrice).toInt()} ${l10n.currency}',
                  ),
                  if (booking.childrenCount > 0)
                    _priceRow(
                      theme,
                      booking.childPrice == 0
                          ? (isAr
                              ? '${booking.childrenCount} طفل (مجاناً)'
                              : '${booking.childrenCount} Child (Free)')
                          : (isAr
                              ? '${booking.childrenCount} طفل × ${booking.childPrice.toInt()} ر.س'
                              : '${booking.childrenCount} Child × ${booking.childPrice.toInt()} SAR'),
                      booking.childPrice == 0
                          ? (isAr ? 'مجاناً' : 'Free')
                          : '${(booking.childrenCount * booking.childPrice).toInt()} ${l10n.currency}',
                    ),
                  const Divider(height: 16),
                  _priceRow(
                    theme,
                    l10n.total_price,
                    '${booking.totalPrice.toInt()} ${l10n.currency}',
                    bold: true,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Cancel button (tourist, pending only) ─────────────────
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
                      content: Text(isAr
                          ? 'هل أنت متأكد أنك تريد إلغاء هذا الحجز؟'
                          : 'Are you sure you want to cancel this booking?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(isAr ? 'لا' : 'No')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(isAr ? 'نعم، إلغاء' : 'Yes, Cancel',
                                style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref
                        .read(marketplaceRepositoryProvider)
                        .updateBookingStatus(
                            booking.bookingId, BookingStatus.rejected);
                    if (context.mounted) Navigator.pop(context);
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
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
              child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _priceRow(ThemeData theme, String label, String value,
      {bool bold = false, Color? color}) {
    final style = bold
        ? theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: color)
        : theme.textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
