import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/core/utils/booking_status_helper.dart';
import 'package:athar_app/features/bookings/logic/booking_repository.dart';
import 'package:athar_app/features/bookings/screens/booking_view_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Renders a single booking entry in the profile booking-history tab.
/// Shows the trip thumbnail, title, city, status chip, and — for tutors
/// with a pending booking — accept/reject action buttons.
class ProfileBookingItem extends ConsumerWidget {
  final BookingModel booking;
  final UserModel user;

  const ProfileBookingItem({
    super.key,
    required this.booking,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isHighContrast = ref.watch(settingsProvider).highContrast;
    final isTutor = user is TutorModel;
    final b = booking;
    final statusColor = bookingStatusColor(b.status, theme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighContrast
              ? theme.colorScheme.onSurface
              : theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: isHighContrast
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (b.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: b.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    memCacheWidth: 200,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder: (_, __) => Container(
                      width: 64,
                      height: 64,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported_outlined, size: 28),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.tripTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    if (b.tripCity.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 15, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              b.tripCity,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BookingViewScreen(booking: b)),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.view_details,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  bookingStatusLabel(status: b.status, isGuide: isTutor, l10n: l10n),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (isTutor && b.status == BookingStatus.pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHighContrast ? theme.colorScheme.primary : Colors.green,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => ref
                        .read(bookingRepositoryProvider)
                        .acceptBooking(b.bookingId, b.touristId),
                    child: Text(l10n.accept_booking),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: isHighContrast ? theme.colorScheme.onSurface : Colors.red,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => ref
                        .read(bookingRepositoryProvider)
                        .updateBookingStatus(b.bookingId, BookingStatus.rejected, b.touristId),
                    child: Text(
                      l10n.reject_booking,
                      style: TextStyle(
                        color: isHighContrast ? theme.colorScheme.onSurface : Colors.red,
                      ),
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
}
