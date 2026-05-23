import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/core/theme/app_theme.dart';

class RecommendedItemDetails extends StatelessWidget {
  final String title;
  final String titleArabic;
  final String image;
  final String category;
  final String location;

  const RecommendedItemDetails({
    super.key,
    required this.title,
    required this.titleArabic,
    required this.image,
    required this.category,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: image,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 280,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 280,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported_outlined,
                        size: 48),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                 child: Container(
                 decoration: BoxDecoration(
                 color: isHighContrast
                 ? theme.colorScheme.onSurface
                 : Colors.black.withValues(alpha: 0.35),
                 shape: BoxShape.circle,
                ),
                 child: IconButton(
                 icon: Icon(
                 Icons.arrow_back,
                 color: theme.colorScheme.onPrimary,
                 ),
                onPressed: () => Navigator.pop(context),
                     ),
                 ),
                ),
              ],
            ),

            // Details Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
               ),
             border: isHighContrast
            ? Border.all(color: theme.colorScheme.onSurface, width: 2)
            : null,
           ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.category,
                          size: 18,
                          color: isHighContrast
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          category,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                 Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.location_on,
                          size: 18,
                          color: isHighContrast
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.textTheme.bodyMedium,
                        ),
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
