import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? titleColor;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.titleColor,
    this.showDivider =
        false, // تم تغيير القيمة الافتراضية إلى false لإزالة الخطوط
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // استخدام ألوان الثيم الممررة في AppTheme
    final Color contentColor = enabled
        ? (titleColor ??
            theme.textTheme.bodyLarge?.color ??
            theme.colorScheme.onSurface)
        : theme.disabledColor;

    return Column(
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12), // لإعطاء تأثير ضغط متناسق
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    size: 22,
                    color: enabled
                        ? theme
                            .colorScheme.primary // استخدام اللون الرئيسي للثيم
                        : theme.disabledColor,
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: contentColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: leadingIcon != null ? 54 : 16,
            endIndent: 16,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}
