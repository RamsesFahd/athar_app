import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  final String title;
  final String description;
  final String progressLabel;
  final IconData icon;
  final bool isEarned;
  final Color? color;

  const BadgeCard({
    super.key,
    required this.title,
    required this.description,
    required this.progressLabel,
    required this.icon,
    required this.isEarned,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;

    final cardColor = isEarned
        ? accentColor.withValues(alpha: 0.08)
        : theme.colorScheme.surface;

    final borderColor = isEarned
        ? accentColor.withValues(alpha: 0.22)
        : theme.dividerColor.withValues(alpha: 0.12);

    final iconBgColor = isEarned
        ? accentColor.withValues(alpha: 0.14)
        : theme.colorScheme.primary.withValues(alpha: 0.08);

    final iconColor = isEarned
        ? accentColor
        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.78);

    final chipBgColor = isEarned
        ? accentColor.withValues(alpha: 0.12)
        : theme.colorScheme.primary.withValues(alpha: 0.06);

    final chipBorderColor = isEarned
        ? accentColor.withValues(alpha: 0.18)
        : theme.dividerColor.withValues(alpha: 0.10);

    final chipTextColor = isEarned
        ? accentColor
        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.25,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: chipBgColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: chipBorderColor),
            ),
            child: Text(
              isEarned ? 'Completed' : progressLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: chipTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}