import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripApprovalsScreen extends ConsumerWidget {
  const TripApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<TripModel>>(
      stream: ref.watch(adminRepositoryProvider).getPendingTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_travel_outlined,
                    size: 72,
                    color: AppColors.primary.withValues(alpha: 0.15)),
                const SizedBox(height: 16),
                Text(l10n.adminNoTripsPending,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _TripApprovalCard(trip: trips[index]),
        );
      },
    );
  }
}

class _TripApprovalCard extends ConsumerWidget {
  final TripModel trip;
  const _TripApprovalCard({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(adminRepositoryProvider);
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip image
          if (trip.imageUrl.isNotEmpty)
            Image.network(
              trip.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined,
                    size: 40, color: Colors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + city
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        trip.titleAr,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${trip.cityAr} - ${trip.cityEn}',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Details
                _InfoRow(
                    icon: Icons.person_outline,
                    label: l10n.adminGuideLabel,
                    value: trip.guide),
                _InfoRow(
                    icon: Icons.business_outlined,
                    label: l10n.adminCompanyLabel,
                    value: trip.company),
                _InfoRow(
                    icon: Icons.payments_outlined,
                    label: l10n.adminPriceLabel,
                    value: trip.price),
                _InfoRow(
                    icon: Icons.verified_outlined,
                    label: l10n.adminLicenseLabel,
                    value: trip.license),
                if (trip.tutorId != null)
                  _InfoRow(
                      icon: Icons.fingerprint,
                      label: l10n.adminTutorIdLabel,
                      value: trip.tutorId!),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await repo.rejectTrip(trip.id, tutorId: trip.tutorId ?? '');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.adminTripRejected),
                                  backgroundColor: Colors.red),
                            );
                          }
                        },
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(l10n.adminReject),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await repo.approveTrip(trip.id, tutorId: trip.tutorId ?? '');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.adminTripApproved),
                                  backgroundColor: Colors.green),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(l10n.adminApprove),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
