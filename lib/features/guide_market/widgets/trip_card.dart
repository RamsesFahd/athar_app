import 'package:flutter/material.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final bool isGridView;

  const TripCard({
    super.key,
    required this.trip,
    this.isGridView = true,
  });

  @override
 Widget build(BuildContext context) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);

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
        ? _buildGridContent(context, isAr, l10n, theme) 
        : _buildListContent(context, isAr, l10n, theme),
  );
}
Widget _buildGridContent(
  BuildContext context,
  bool isAr,
  AppLocalizations l10n,
  ThemeData theme,
) {
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return Stack(
    children: [
      // 1. الصورة
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            trip.imageUrl,
            fit: BoxFit.cover,
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

      // 3. المحتوى
      Positioned(
        left: 12,
        right: 12,
        bottom: 12,
        child: SizedBox(
          height: 110, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
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

               // Location
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
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(), 

              // Price + Button
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          trip.price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // الزر
                  GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TripDetailsScreen(trip: trip),
    ),
  ),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      isAr ? "التفاصيل" : "Details",
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
) {
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return SizedBox(
    height: 150,
    child: Row(
      children: [
        // الصورة
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            trip.imageUrl,
            width: 130,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
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

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الموقع
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
                  ],
                ),

                const SizedBox(height: 8),

                // العنوان
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

                // التصنيف
                if (trip.accessibilityFeatures.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: trip.accessibilityFeatures.map((key) {
                      final label = switch (key) {
                        'wheelchair' => isAr ? 'صديق للإعاقة' : 'Accessible',
                        'family' => isAr ? 'مناسب للعائلات' : 'Family Friendly',
                        _ => key,
                      };
                      return _buildTag(label, theme);
                    }).toList(),
                  ),

                const Spacer(),

                // السعر + الزر
                Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trip.price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAr ? '﷼' : 'SAR',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    _buildActionButton(context, isAr, theme),
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

Widget _buildActionButton(BuildContext context, bool isAr, ThemeData theme) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailsScreen(trip: trip)),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAr ? "عرض التفاصيل" : "View Details",
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
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