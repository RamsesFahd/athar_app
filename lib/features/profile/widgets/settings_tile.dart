import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  // Tile title
  final String title;

  // Tile subtitle 
  final String? subtitle;

  // Leading icon 
  final IconData? leadingIcon;

  // Trailing widget  زي Switch
  final Widget? trailing;

  // Tap action
  final VoidCallback? onTap;

  // Enable / Disable tile
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      // Disable tapping if not enabled
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        // Tile padding
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

        // Tile style 
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            // Leading icon
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: 12),
            ],

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title text
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Subtitle text
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing widget (Switch) OR default arrow
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
          ],
        ),
      ),
    );
  }
}