import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class GuideCard extends StatelessWidget {
  final Map<String, dynamic> guide;
  final VoidCallback onTap;

  const GuideCard({super.key, required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final name = guide['name'] as String? ?? '';
    final rating = guide['rating'];
    final experienceYears = guide['exp'];
    final languages = (guide['languages'] as List?)?.cast<String>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.workspace_premium,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                        ],
                      ),
                      Text(
                        '${l10n.rating}: $rating  •  ${l10n.experience}: $experienceYears',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            '${l10n.languages} ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              languages.join(' • '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: colorScheme.primary),
                  onPressed: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}