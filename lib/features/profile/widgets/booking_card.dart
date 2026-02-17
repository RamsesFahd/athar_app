
import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final String detailsText;

  const BookingCard({
    super.key,
    required this.detailsText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Card background
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip name + Details (disabled)
          Row(
            children: [
              // Trip name placeholder
              Expanded(child: _bar(180, 18)),
              const SizedBox(width: 10),

              // Details button
              OutlinedButton(
                onPressed: null,
                child: Text(detailsText),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // With + guide placeholder
          _bar(150, 14),

          const SizedBox(height: 12),

          // Date placeholder
          _bar(120, 14),

          const SizedBox(height: 10),

          // Time + duration placeholder
          _bar(200, 14),
        ],
      ),
    );
  }

  // Placeholder bar
  Widget _bar(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        // Grey placeholder
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}