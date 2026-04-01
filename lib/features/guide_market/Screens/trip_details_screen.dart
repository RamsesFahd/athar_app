import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:athar_app/features/guide_market/screens/booking_details_screen.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripDetailsScreen extends ConsumerWidget {
  final TripModel trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final isCompany = trip.tutorType == 'company';

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ────────────────────────────────────────
                Image.network(
                  trip.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──────────────────────────────────────
                      Text(trip.getTitle(isAr),
                          style: theme.textTheme.displayLarge),
                      const SizedBox(height: 12),

                      // ── Price display ──────────────────────────────
                      _buildPriceRow(theme, isAr),
                      const SizedBox(height: 16),

                      // ── Accessibility badges ───────────────────────
                      if (trip.accessibilityFeatures.isNotEmpty)
                        _buildAccessibilityBadges(theme, isAr),

                      const SizedBox(height: 20),

                      // ── About section ──────────────────────────────
                      Text(l10n.about_trip,
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 12),

                      MarkdownBody(
                        data: trip.getDescription(isAr),
                        styleSheet: MarkdownStyleSheet(
                          p: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                          listBullet: TextStyle(
                              color: theme.colorScheme.primary, fontSize: 16),
                          strong: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Tutor / company info ───────────────────────
                      if (isCompany) ...[
                        _buildInfoRow(context, Icons.business_outlined,
                            '${l10n.company}: ${trip.company}'),
                        _buildInfoRow(context, Icons.verified_outlined,
                            '${l10n.license}: ${trip.license}'),
                      ] else ...[
                        _buildInfoRow(context, Icons.person_outline,
                            '${l10n.guide}: ${trip.guide}'),
                        _buildInfoRow(context, Icons.verified_outlined,
                            '${l10n.license}: ${trip.license}'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top navigation buttons ────────────────────────────────
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // ── Book Now button ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(bookingNotifierProvider.notifier)
                        .startBooking(trip);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingDetailsScreen(trip: trip),
                      ),
                    );
                  },
                  child: Text(l10n.book_now),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(ThemeData theme, bool isAr) {
    final adultLabel = isAr
        ? '${trip.adultPrice.toInt()} ر.س / بالغ'
        : '${trip.adultPrice.toInt()} SAR / Adult';
    final childLabel = trip.childPrice == 0
        ? (isAr ? 'أطفال: مجاناً' : 'Children: Free')
        : (isAr
            ? '${trip.childPrice.toInt()} ر.س / طفل'
            : '${trip.childPrice.toInt()} SAR / Child');

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Chip(
          avatar: Icon(Icons.payments_outlined,
              size: 16, color: theme.colorScheme.primary),
          label: Text(adultLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          backgroundColor:
              theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          side: BorderSide.none,
        ),
        Chip(
          avatar: Icon(Icons.child_care,
              size: 16, color: theme.colorScheme.secondary),
          label: Text(childLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          backgroundColor:
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
          side: BorderSide.none,
        ),
      ],
    );
  }

  Widget _buildAccessibilityBadges(ThemeData theme, bool isAr) {
    const badgeInfo = {
      'wheelchair': (
        icon: Icons.accessible,
        labelEn: 'Wheelchair Accessible',
        labelAr: 'مناسب لذوي الإعاقة الحركية',
      ),
      'family': (
        icon: Icons.family_restroom,
        labelEn: 'Family Friendly',
        labelAr: 'مناسب للعائلات والأطفال',
      ),
    };

    final chips = trip.accessibilityFeatures
        .where(badgeInfo.containsKey)
        .map((key) {
      final info = badgeInfo[key]!;
      return Chip(
        avatar: Icon(info.icon, size: 16, color: theme.colorScheme.tertiary),
        label: Text(isAr ? info.labelAr : info.labelEn,
            style: theme.textTheme.bodySmall),
        backgroundColor:
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        side: BorderSide.none,
      );
    }).toList();

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(spacing: 8, runSpacing: 4, children: chips),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
