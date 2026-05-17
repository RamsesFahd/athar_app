import 'package:flutter/material.dart';

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
    final isHighContrast = theme.colorScheme.primary == Colors.black;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            Stack(
              children: [
                Image.network(
                  image,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                 child: Container(
                 decoration: BoxDecoration(
                 color: isHighContrast
                 ? Colors.black
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
            ? Border.all(color: Colors.black, width: 2)
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
                    children: [
                      Icon(
                      Icons.category,
                      size: 18,
                      color: isHighContrast
                      ? Colors.black
                      : theme.colorScheme.primary,
                       ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                 Row(
  children: [
    Icon(
      Icons.location_on,
      size: 18,
      color: isHighContrast
          ? Colors.black
          : theme.colorScheme.primary,
    ),
                      const SizedBox(width: 6),
                      Text(
                        location,
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