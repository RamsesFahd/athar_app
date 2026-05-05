import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';

class AttractionCard extends StatelessWidget {
  final AttractionModel attraction;
  final bool isGridView;

  const AttractionCard({
    super.key,
    required this.attraction,
    this.isGridView = true,
  });

  static Color _hexColor(String code) {
    final n = code.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$n', radix: 16));
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttractionDetailsScreen(attraction: attraction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final accent = _hexColor(attraction.categoryColorCode);

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
    return Stack(
      children: [
        // 1. Full-cover hero image
        Positioned.fill(
          child: Hero(
            tag: 'attraction-${attraction.id}-hero',
            child: Image.network(
              attraction.mainImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 36,
                ),
              ),
            ),
          ),
        ),

        // 2. Bottom gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
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

        // 3. Content overlay — name, city
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                attraction.getName(isAr),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: isAr
                    ? GoogleFonts.ibmPlexSansArabic(
                        textStyle: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      )
                    : GoogleFonts.playfairDisplay(
                        textStyle: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 13, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      attraction.getCity(isAr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 4. Invisible full-area tap
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: () => _openDetails(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildList(
      BuildContext context, bool isAr, ThemeData theme, Color accent) {
    return SizedBox(
      height: 130,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Row(
          children: [
            // Thumbnail
            Hero(
              tag: 'attraction-${attraction.id}-hero',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: Image.network(
                  attraction.mainImage,
                  width: 120,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 130,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
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
                    // Title
                    Text(
                      attraction.getName(isAr),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: isAr
                          ? GoogleFonts.ibmPlexSansArabic(
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            )
                          : GoogleFonts.playfairDisplay(
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    // City
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: accent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attraction.getCity(isAr),
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
                    // Category
                    Text(
                      attraction.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
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
