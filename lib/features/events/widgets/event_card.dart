import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/events/screens/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isGridView;

  const EventCard({
    super.key,
    required this.event,
    this.isGridView = true,
  });

  // Matches the event badge color used in MapResultsSheet (colorScheme.secondary)
  static const Color eventColor = Color(0xFFCC9A53);

  static Color typeColor(EventType _) => eventColor;

  void _openDetails(BuildContext context) {
    try {
      precacheImage(CachedNetworkImageProvider(event.imageUrl), context);
    } catch (_) {}
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final accent = typeColor(event.eventType);

    return Container(
      margin: const EdgeInsets.all(4),
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
          ? _buildGrid(context, isAr, theme, accent)
          : _buildList(context, isAr, theme, accent),
    );
  }

  Widget _buildGrid(
      BuildContext context, bool isAr, ThemeData theme, Color accent) {
    final largeText = MediaQuery.textScalerOf(context).scale(1.0) > 1.2;
    final dateStr =
        DateFormat('d MMM', isAr ? 'ar' : 'en').format(event.eventDate);

    return InkWell(
      onTap: () => _openDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      size: 36,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: isAr ? null : 10,
                  left: isAr ? 10 : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.getTitle(isAr),
                    maxLines: largeText ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: isAr
                        ? theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          )
                        : GoogleFonts.playfairDisplay(
                            textStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 11),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          event.getRegion(isAr),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildList(
      BuildContext context, bool isAr, ThemeData theme, Color accent) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cardExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 34).toDouble();
    final cardHeight = 130 + cardExtra;
    final dateStr =
        DateFormat('d MMM yyyy', isAr ? 'ar' : 'en').format(event.eventDate);

    return SizedBox(
      height: cardHeight,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: 120,
                height: cardHeight,
                fit: BoxFit.cover,
                memCacheWidth: 400,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) => Container(
                  width: 120,
                  height: cardHeight,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 120,
                  height: cardHeight,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.getTitle(isAr),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: isAr
                          ? theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            )
                          : GoogleFonts.playfairDisplay(
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: accent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.getRegion(isAr),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
