import 'package:athar_app/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AllBookingsScreen extends ConsumerWidget {
  const AllBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<BookingModel>>(
      stream: ref.watch(adminRepositoryProvider).getAllBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_online_outlined,
                    size: 72, color: AppColors.primary.withValues(alpha: 0.15)),
                const SizedBox(height: 16),
                Text(l10n.adminNoBookings,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              _BookingTile(booking: bookings[index]),
        );
      },
    );
  }
}

class _BookingTile extends StatelessWidget {
  final BookingModel booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                booking.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.tripTitle,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    text: Text(
                      '${booking.date}  •  ${booking.timeSlot}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _DetailRow(
                    icon: Icons.people_outline,
                    text: Text(
                      l10n.adminBookingPeopleSummary(
                          booking.adultsCount, booking.childrenCount),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _DetailRow(
                      icon: Icons.payments_outlined,
                      text: CurrencyFormatter.format(booking.totalPrice,
                          decimals: 2)),
                  const SizedBox(height: 4),
                  Text(l10n.adminTouristId(booking.touristId),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis),
                  Text(l10n.adminTutorId(booking.tutorId),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Widget text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Expanded(child: text),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case BookingStatus.approved:
        color = Colors.green;
        label = l10n.adminStatusApproved;
      case BookingStatus.completed:
        color = Colors.blue;
        label = l10n.contributionCompleted;
      case BookingStatus.rejected:
        color = Colors.red;
        label = l10n.adminStatusRejected;
      default:
        color = Colors.orange;
        label = l10n.adminStatusPending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
