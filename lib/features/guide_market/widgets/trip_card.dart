import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripCard extends ConsumerWidget {
  final TripModel trip;
  final bool isGridView;

  const TripCard({
    super.key,
    required this.trip,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final isFullyBooked = trip.isPrivate
        ? ref
              .watch(bookedDatesForTripProvider(trip.id))
              .whenOrNull(data: (dates) => trip.isPrivateFullyBooked(dates)) ??
            false
        : trip.isFullyBooked;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isGridView
          ? _buildGridContent(context, isAr, l10n, theme, isFullyBooked)
          : _buildListContent(context, isAr, l10n, theme, isFullyBooked),
    );
  }

  Widget _buildGridContent(
    BuildContext context,
    bool isAr,
    AppLocalizations l10n,
    ThemeData theme,
    bool isFullyBooked,
  ) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // 1. Image
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CachedNetworkImage(
              imageUrl: trip.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 600,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (_, __) => Container(
                color: colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (_, __, ___) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 36,
                ),
              ),
            ),
          ),
        ),

        // 2. Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),

        // 3. Fully booked dim overlay
        if (isFullyBooked)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),

        // 4. Trip-type badge (top-start)
        PositionedDirectional(
          top: 10,
          start: 10,
          child: _buildTripTypeBadge(l10n, isFullyBooked: false),
        ),

        // 5. Fully booked badge (top-end)
        if (isFullyBooked)
          PositionedDirectional(
            top: 10,
            end: 10,
            child: _buildFullyBookedBadge(l10n),
          ),

        // 6. Content
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: SizedBox(
            height: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.getTitle(isAr),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trip.getCity(isAr),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Row(
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/saudi_riyal.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip.price,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: isFullyBooked
                          ? null
                          : () {
                              try {
                                precacheImage(
                                    CachedNetworkImageProvider(trip.imageUrl),
                                    context);
                              } catch (_) {}
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TripDetailsScreen(trip: trip),
                                ),
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isFullyBooked
                              ? Colors.white.withValues(alpha: 0.25)
                              : colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isFullyBooked
                              ? l10n.tripFullyBooked
                              : l10n.tripCardDetails,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListContent(
    BuildContext context,
    bool isAr,
    AppLocalizations l10n,
    ThemeData theme,
    bool isFullyBooked,
  ) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 150,
      child: Row(
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: trip.imageUrl,
                  width: 130,
                  height: 150,
                  fit: BoxFit.cover,
                  memCacheWidth: 400,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => Container(
                    width: 130,
                    height: 150,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 130,
                    height: 150,
                    color: colorScheme.surface,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              if (isFullyBooked)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location + type badge row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.getCity(isAr),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildTripTypeBadge(l10n, isFullyBooked: isFullyBooked),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    trip.getTitle(isAr),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),

                  const SizedBox(height: 6),

                  if (trip.accessibilityFeatures.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: trip.accessibilityFeatures.map((key) {
                        final label = switch (key) {
                          'wheelchair' =>
                            l10n.tripAccessibilityWheelchairShort,
                          'family' => l10n.tripAccessibilityFamilyShort,
                          _ => key,
                        };
                        return _buildTag(label, theme);
                      }).toList(),
                    ),

                  const Spacer(),

                  Row(
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/saudi_riyal.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.price,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildActionButton(context, isAr, theme, l10n,
                          isFullyBooked: isFullyBooked),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeBadge(AppLocalizations l10n,
      {required bool isFullyBooked}) {
    final isPrivate = trip.isPrivate;
    const color = Colors.teal;
    final label = isPrivate ? l10n.tripTypePrivate : l10n.tripTypeShared;
    final icon = isPrivate ? Icons.lock_outline : Icons.group_outlined;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullyBookedBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        l10n.tripFullyBooked,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isAr,
    ThemeData theme,
    AppLocalizations l10n, {
    required bool isFullyBooked,
  }) {
    return GestureDetector(
      onTap: isFullyBooked
          ? null
          : () {
              try {
                precacheImage(
                    CachedNetworkImageProvider(trip.imageUrl), context);
              } catch (_) {}
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TripDetailsScreen(trip: trip)),
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isFullyBooked
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isFullyBooked ? l10n.tripFullyBooked : l10n.tripCardViewDetails,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isFullyBooked
                ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                : theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
