/*import 'package:flutter/material.dart';

class SavedItemCard extends StatelessWidget {
  const SavedItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Card background
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [

          // Image placeholder
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Item name placeholder
                _bar(width: 150, height: 16),

                const SizedBox(height: 10),

                // Location placeholder
                _bar(width: 120, height: 14),

                const SizedBox(height: 12),

                // Type badge placeholder (Event / Guide / Landmark)
                _bar(width: 80, height: 24, radius: 10),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Heart icon (Saved icon)
          const Icon(Icons.favorite, color: Colors.orange, size: 22),
        ],
      ),
    );
  }

  // Simple grey bar for placeholder text
  Widget _bar({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:athar_app/core/theme/app_colors.dart';

class SavedCard extends StatelessWidget {
  const SavedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Card background
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name placeholder
                _bar(150, 16),

                const SizedBox(height: 10),

                // Location placeholder
                _bar(120, 14),

                const SizedBox(height: 12),

                // Type badge placeholder (Event/Guide/Landmark)
                _bar(80, 24, radius: 10),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Heart icon (Saved)
          const Icon(Icons.favorite, color: AppColors.henna500, size: 22),
        ],
      ),
    );
  }

  // Placeholder bar
  Widget _bar(double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        // Grey placeholder
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}