import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExploreHeritageHomeCard extends StatelessWidget {
  final String title;
  final String image;
  final String categoryLabel;
  final String locationLabel;
  final VoidCallback? onTap;

  const ExploreHeritageHomeCard({
    super.key,
    required this.title,
    required this.image,
    required this.categoryLabel,
    required this.locationLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              try {
                precacheImage(CachedNetworkImageProvider(image), context);
              } catch (_) {}
              onTap!();
            },
      child: Container(
      width: 270,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),


          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.55),
            width: 1,
          ),
          boxShadow: [
  BoxShadow(
    color: theme.shadowColor.withValues(alpha: 0.10),
    blurRadius: 18,
    offset: const Offset(0, 8),
  ),
],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Badge
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: image,
                  height: 195,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => Container(
                    height: 195,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 195,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      categoryLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),


            // Title + Location
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18) - 2,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.iconTheme.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        locationLabel,

                        
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}