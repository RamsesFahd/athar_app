import 'package:flutter/material.dart';

class SavedCard extends StatelessWidget {
  const SavedCard({
    super.key,
    required this.title,
    required this.location,
    required this.typeText,
    required this.isSaved,
    this.dateText,
    this.onTap,
  });

  final String title;
  final String location;
  final String typeText;
  final bool isSaved;
  final String? dateText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Icon(
                Icons.image_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + heart
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.favorite,
                          size: 18,
                          color: isSaved
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location + optional date
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (dateText != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateText!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Type chip + chevron
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Text(
                            typeText,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ],
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