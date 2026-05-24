import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/theme/app_theme.dart';
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

  String _categoryLabel(bool isAr) {
    if (!isAr) return attraction.category;

    switch (attraction.category.toLowerCase()) {
      case 'heritage':
        return 'تراث';
      case 'nature':
        return 'طبيعة';
      case 'arts':
        return 'فنون';
      case 'modern':
        return 'عصري';
      default:
        return attraction.category;
    }
  }

  void _openDetails(BuildContext context) {
    // Fire-and-forget: warms memory cache during the ~300 ms route transition.
    try {
      precacheImage(CachedNetworkImageProvider(attraction.mainImage), context);
    } catch (_) {}
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
    final accent = theme.isHighContrast
        ? theme.colorScheme.primary
        : _hexColor(attraction.categoryColorCode);

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
    return InkWell(
      onTap: () => _openDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Full-cover hero image
          Expanded(
            flex: 5, // ✨ خلينا الصورة تاخذ أغلب مساحة الكارد
            child: Hero(
              tag: 'attraction-${attraction.id}-hero',
              child: CachedNetworkImage(
                imageUrl: attraction.mainImage,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: double.infinity,
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
          // ✨ حذفنا الـ gradient لأن النص صار تحت الصورة

          // 3. Content overlay — name, city
          Expanded(
            flex: 2, // ✨ مساحة النص أصغر بكثير من الصورة
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    attraction.getName(isAr),

                    // ✨ اسم المعلم صار أصغر
                    maxLines: largeText ? 2 : 1,

                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 11, // ✨ تصغير الايقونة
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          attraction.getCity(isAr),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.isHighContrast
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),

                            // ✨ تصغير الموقع
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

          // 4. Invisible full-area tap
          // ✨ صار الـ InkWell فوق بدل Positioned.fill
        ],
      ),
    );
  }

  Widget _buildList(
      BuildContext context, bool isAr, ThemeData theme, Color accent) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cardExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 34).toDouble();
    final cardHeight = 130 + cardExtra;

    return SizedBox(
      height: cardHeight,
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
                child: CachedNetworkImage(
                  imageUrl: attraction.mainImage,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
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
                      _categoryLabel(isAr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.isHighContrast
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface
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
