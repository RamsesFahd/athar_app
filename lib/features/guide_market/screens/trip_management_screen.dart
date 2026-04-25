import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/guide_market/Screens/add_trip_screen.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripManagementScreen extends ConsumerWidget {
  const TripManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
            isAr ? 'هذه الميزة للمرشدين فقط' : 'This feature is for guides only',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

// ── Tutor hub ─────────────────────────────────────────────────────────────────

class _TutorTripHub extends ConsumerWidget {
  const _TutorTripHub({
    required this.tutor,
    required this.theme,
    required this.isAr,
  });

  final TutorModel tutor;
  final ThemeData theme;
  final bool isAr;

  bool get _canAdd =>
      tutor.verificationStatus == VerificationStatus.verified &&
      tutor.isCredentialValid &&
      (tutor.phoneNumber != null && tutor.phoneNumber!.isNotEmpty);

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
    switch (status) {
      case 'approved':
        return isAr ? 'مقبول' : 'Approved';
      case 'rejected':
        return isAr ? 'مرفوض' : 'Rejected';
      default:
        return isAr ? 'قيد المراجعة' : 'Pending';
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, TripModel trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isAr ? 'حذف الرحلة' : 'Delete Trip'),
        content: Text(
          isAr
              ? 'هل أنت متأكد أنك تريد حذف "${isAr ? trip.titleAr : trip.titleEn}"؟\nلا يمكن التراجع عن هذه العملية.'
              : 'Are you sure you want to delete "${trip.titleEn}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isAr ? 'حذف' : 'Delete'),
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
            content:
                Text(isAr ? 'تم حذف الرحلة بنجاح' : 'Trip deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: _canAdd
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTripScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(isAr ? 'إضافة رحلة' : 'Add Trip'),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<TripModel>>(
        stream: ref
            .read(marketplaceRepositoryProvider)
            .fetchTutorTrips(tutor.uId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final trips = snapshot.data ?? [];

          if (trips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 72,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'لا توجد رحلات بعد' : 'No trips yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_canAdd)
                      Text(
                        isAr
                            ? 'اضغط على + لإضافة أول رحلة'
                            : 'Tap + to add your first trip',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        isAr
                            ? 'أكمل التوثيق أولاً لتتمكن من إضافة رحلات'
                            : 'Complete verification first to add trips',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
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
            itemBuilder: (ctx, i) =>
                _TripCard(
                  trip: trips[i],
                  theme: theme,
                  isAr: isAr,
                  statusColor: _statusColor(trips[i].status),
                  statusLabel: _statusLabel(trips[i].status),
                  onEdit: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddTripScreen(initialTrip: trips[i]),
                    ),
                  ),
                  onDelete: () => _confirmDelete(ctx, ref, trips[i]),
                ),
          );
        },
      ),
      ),
    );
  }
}

// ── Trip card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.theme,
    required this.isAr,
    required this.statusColor,
    required this.statusLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final TripModel trip;
  final ThemeData theme;
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
                child: Image.network(
                  trip.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
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
                        label: Text(isAr ? 'تعديل' : 'Edit'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 17),
                        label: Text(isAr ? 'حذف' : 'Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
                isAr ? 'رحلاتي' : 'My Trips',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isAr
                    ? 'يمكنك عرض حجوزاتك وإدارة رحلاتك من تبويب "الحجوزات" في ملفك الشخصي'
                    : 'View and manage your bookings from the "Bookings" tab in your profile',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.55),
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
