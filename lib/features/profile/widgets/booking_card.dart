import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final String title;
  final String guide;
  final String dateText;
  final String timeText;
  final String duration;
  final String detailsLabel;
  final String? imageUrl;
  final VoidCallback? onDetails;

  const BookingCard({
    super.key,
    required this.title,
    required this.guide,
    required this.dateText,
    required this.timeText,
    required this.duration,
    required this.detailsLabel,
    this.imageUrl,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => Container(
                    height: 140,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 140,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 36,
                            maxWidth: 128,
                          ),
                          child: OutlinedButton(
                              onPressed: onDetails,
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                detailsLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Guide: $guide",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildInfoItem(
                            theme, Icons.calendar_today_outlined, dateText),
                        _buildInfoItem(
                            theme, Icons.access_time, "$timeText ($duration)"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.08)),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
