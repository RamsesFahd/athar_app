

import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.title,
    required this.guide,
    required this.dateText,
    required this.timeText,
    required this.durationText,
    required this.withLabel,
    required this.detailsLabel,
    this.onDetails,
  });

  final String title;
  final String guide;
  final String dateText;
  final String timeText;
  final String durationText;
  final String withLabel;
  final String detailsLabel;

  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip title
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),

                // With guide text
                Text(
                  '$withLabel: $guide',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 10),

                // Date & time chips
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      icon: Icons.calendar_month_outlined,
                      text: dateText,
                    ),
                    _Chip(
                      icon: Icons.access_time_outlined,
                      text: '$timeText ($durationText)',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Details button
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: onDetails,
              child: Text(
                detailsLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}