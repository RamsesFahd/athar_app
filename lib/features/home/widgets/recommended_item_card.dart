
import 'package:flutter/material.dart';
import '../widgets/recommended_item_details.dart';

class RecommendedItemCard extends StatelessWidget {
  final String title;
  final String titleArabic;
  final String image;
  final String category;
  final String location;

  const RecommendedItemCard({
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
    final isHighContrast = theme.colorScheme.primary == Colors.black;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecommendedItemDetails(
              title: title,
              titleArabic: titleArabic,
              image: image,
              category: category,
              location: location,
            ),
          ),
        );
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),

          border: Border.all(
           color: isHighContrast
           ? Colors.black
           : theme.dividerColor.withValues(alpha: 0.55),
           width: isHighContrast ? 2 : 1,
          ),


         boxShadow: isHighContrast
         ? []
         : [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
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
                Image.network(
                  image,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Title + Location
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize:
                          (theme.textTheme.titleLarge?.fontSize ?? 18) - 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isHighContrast ? Colors.black : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
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