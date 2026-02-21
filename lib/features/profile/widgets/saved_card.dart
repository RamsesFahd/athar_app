import 'package:flutter/material.dart';

class SavedCard extends StatelessWidget {
  final String title;
  final String location;
  final String typeText;
  final String image;
  final bool isSaved;
  final String? dateText;
  final VoidCallback? onTap;

  const SavedCard({
    super.key,
    required this.title,
    required this.location,
    required this.typeText,
    required this.image,
    required this.isSaved,
    this.dateText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(11)),
                child: Image.network(
                  image,
                  width: 100,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(Icons.image_outlined,
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(title,
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Icon(isSaved ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isSaved
                                  ? theme.colorScheme.primary
                                  : theme.disabledColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 12, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(location, style: theme.textTheme.bodySmall),
                            ],
                          ),
                          if (dateText != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_month_outlined,
                                    size: 12, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(dateText!,
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(typeText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10)),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 12, color: theme.colorScheme.outline),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
