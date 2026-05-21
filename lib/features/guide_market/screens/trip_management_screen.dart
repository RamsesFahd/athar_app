import 'package:cached_network_image/cached_network_image.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/utils/booking_status_helper.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/guide_market/Screens/add_trip_screen.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/screens/booking_view_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripManagementScreen extends ConsumerWidget {
  const TripManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authNotifierProvider).value;

    if (user is TutorModel) {
      return _TutorTripHub(tutor: user, theme: theme, isAr: isAr);
    }

    if (user is TouristModel) {
      return _TouristPlaceholder(theme: theme, isAr: isAr);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Text(
            l10n.tripManagementGuidesOnly,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

// ── Tutor hub ─────────────────────────────────────────────────────────────────

class _TutorTripHub extends ConsumerStatefulWidget {
  const _TutorTripHub({
    required this.tutor,
    required this.theme,
    required this.isAr,
  });

  final TutorModel tutor;
  final ThemeData theme;
  final bool isAr;

  @override
  ConsumerState<_TutorTripHub> createState() => _TutorTripHubState();
}

class _TutorTripHubState extends ConsumerState<_TutorTripHub>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  TutorModel get tutor => widget.tutor;
  ThemeData get theme => widget.theme;
  bool get isAr => widget.isAr;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _canAdd => tutor.canPublishTrips;

  String _blockingHint() {
    final l10n = AppLocalizations.of(context);
    final missing = tutor.missingTripRequirements;
    if (missing.contains('phone_verification')) {
      return l10n.tripManagementVerifyPhoneFirst;
    }
    if (missing.contains('guide_verification')) {
      return l10n.tripManagementCompleteVerificationFirst;
    }
    return l10n.tripManagementCompleteProfileFirst;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'approved':
        return l10n.tripStatusApproved;
      case 'rejected':
        return l10n.tripStatusRejected;
      default:
        return l10n.tripStatusPending;
    }
  }

  Future<void> _confirmDelete(BuildContext context, TripModel trip) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.tripDeleteTitle),
        content:
            Text(l10n.tripDeleteConfirm(isAr ? trip.titleAr : trip.titleEn)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.tripDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(marketplaceRepositoryProvider).deleteTrip(trip.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tripDeletedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.commonErrorWithMessage(e.toString())),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      floatingActionButton: _canAdd
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTripScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.tripAddButton),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.myTrips),
                Tab(text: l10n.profileTabBooking),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTripsTab(l10n),
                  _buildBookingsTab(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsTab(AppLocalizations l10n) {
    return StreamBuilder<List<TripModel>>(
      stream:
          ref.read(marketplaceRepositoryProvider).fetchTutorTrips(tutor.uId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child:
                  Text(l10n.commonErrorWithMessage(snapshot.error.toString())));
        }
        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route_outlined,
                      size: 72,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tripNoTripsYet,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _canAdd ? l10n.tripTapToAddFirst : _blockingHint(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: trips.length,
          itemBuilder: (ctx, i) => _TripCard(
            trip: trips[i],
            theme: theme,
            l10n: l10n,
            isAr: isAr,
            statusColor: _statusColor(trips[i].status),
            statusLabel: _statusLabel(trips[i].status),
            onEdit: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => AddTripScreen(initialTrip: trips[i])),
            ),
            onDelete: () => _confirmDelete(ctx, trips[i]),
          ),
        );
      },
    );
  }

  Widget _buildBookingsTab(AppLocalizations l10n) {
    return StreamBuilder<List<BookingModel>>(
      stream: ref
          .read(marketplaceRepositoryProvider)
          .fetchUserBookings(tutor.uId, tutor.role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child:
                  Text(l10n.commonErrorWithMessage(snapshot.error.toString())));
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return Center(
            child: Text(
              l10n.tripNoBookingsYet,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          );
        }
        final sorted = List<BookingModel>.from(bookings)
          ..sort((a, b) => a.status == BookingStatus.pending ? -1 : 1);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final b = sorted[index];
            return _buildBookingCard(context, b, l10n);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(
      BuildContext context, BookingModel b, AppLocalizations l10n) {
    Color statusColor(BookingStatus s) {
      switch (s) {
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
      }
    }

    final sc = statusColor(b.status);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6))
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
                        color: theme.colorScheme.surfaceContainerHighest),
                    errorWidget: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported_outlined,
                            size: 28)),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.tripTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800, height: 1.25)),
                    if (b.tripCity.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 15, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(b.tripCity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall)),
                      ]),
                    ],
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BookingViewScreen(booking: b))),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(l10n.view_details,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios,
                            size: 12, color: theme.colorScheme.primary),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(
                  bookingStatusLabel(
                      status: b.status, isGuide: true, l10n: l10n),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: sc, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (b.status == BookingStatus.pending) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => ref
                      .read(marketplaceRepositoryProvider)
                      .acceptBooking(b.bookingId, b.touristId),
                  child: Text(l10n.accept_booking),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => ref
                      .read(marketplaceRepositoryProvider)
                      .updateBookingStatus(
                          b.bookingId, BookingStatus.rejected, b.touristId),
                  child: Text(l10n.reject_booking,
                      style: const TextStyle(color: Colors.red)),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

// ── Trip card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.theme,
    required this.l10n,
    required this.isAr,
    required this.statusColor,
    required this.statusLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final TripModel trip;
  final ThemeData theme;
  final AppLocalizations l10n;
  final bool isAr;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = isAr ? trip.titleAr : trip.titleEn;
    final city = isAr ? trip.cityAr : trip.cityEn;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
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
          // Cover image
          if (trip.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: CachedNetworkImage(
                  imageUrl: trip.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, __) => ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // City + price
                Row(
                  children: [
                    if (city.isNotEmpty) ...[
                      Icon(Icons.location_on_outlined,
                          size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(city, style: theme.textTheme.bodySmall),
                      const SizedBox(width: 14),
                    ],
                    Icon(Icons.payments_outlined,
                        size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(trip.price, style: theme.textTheme.bodySmall),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: Text(l10n.tripEdit),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 17),
                        label: Text(l10n.tripDelete),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tourist placeholder ───────────────────────────────────────────────────────

class _TouristPlaceholder extends StatelessWidget {
  const _TouristPlaceholder({required this.theme, required this.isAr});

  final ThemeData theme;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.luggage_outlined,
                  size: 72,
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.myTrips,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.tripManagementTouristHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
