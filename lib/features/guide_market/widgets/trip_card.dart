import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/guide_market/logic/trips_repository.dart';
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
        ? ref.watch(bookedDatesForTripProvider(trip.id)).whenOrNull(
                data: (dates) => trip.isPrivateFullyBooked(dates)) ??
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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final contentExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 40).toDouble();

    return Stack(
      children: [
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

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),

        if (isFullyBooked)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),

        if (isFullyBooked)
          PositionedDirectional(
            top: 10,
            end: 10,
            child: _buildFullyBookedBadge(l10n, theme, isAr),
          ),

        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: SizedBox(
            height: 120 + contentExtra, // extra height prevents button clipping at large text scales
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.getTitle(isAr),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontFamily: isAr ? 'ThmanyahSerifDisplay' : null,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/saudi_riyal.svg',
                            width: 15,
                            height: 15,
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
                    Flexible( // prevents button overflow on constrained card widths
                      child: Align(
                        alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                        child: GestureDetector(
                          onTap: isFullyBooked
                              ? null
                              : () {
                                  try {
                                    precacheImage(
                                        CachedNetworkImageProvider(
                                            trip.imageUrl),
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
                                horizontal: 12, vertical: 6),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cardExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 42).toDouble();
    // 170 gives text and button enough room at maximum text scale
    final cardHeight = 170 + cardExtra;

    return SizedBox(
      height: cardHeight,
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: trip.imageUrl,
                  width: 130,
                  height: cardHeight, // must match card height to prevent vertical overflow
                  fit: BoxFit.cover,
                  memCacheWidth: 400,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => Container(
                    width: 130,
                    height: cardHeight,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 130,
                    height: cardHeight,
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
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    trip.getTitle(isAr),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontFamily: isAr ? 'ThmanyahSerifDisplay' : null,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/saudi_riyal.svg',
                              width: 15,
                              height: 15,
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
                      Flexible( // prevents button overflow on narrower list cards
                        child: Align(
                          alignment: isAr
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: _buildActionButton(context, isAr, theme, l10n,
                              isFullyBooked: isFullyBooked),
                        ),
                      ),
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

  Widget _buildFullyBookedBadge(
    AppLocalizations l10n,
    ThemeData theme,
    bool isAr,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        l10n.tripFullyBooked,
        style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isFullyBooked
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isFullyBooked ? l10n.tripFullyBooked : l10n.tripCardDetails,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
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
  }

