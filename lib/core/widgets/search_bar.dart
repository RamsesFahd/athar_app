import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onToggleView;
  final bool isGridView;
  final bool isFilterActive;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    required this.onToggleView,
    required this.isGridView,
    this.isFilterActive = false,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHighContrast = theme.isHighContrast;
    final l10n = AppLocalizations.of(context);

    final defaultBorderColor = isHighContrast
        ? colorScheme.outline
        : colorScheme.primary.withValues(alpha: 0.10);
    final focusedBorderColor = isHighContrast
        ? colorScheme.primary
        : colorScheme.primary.withValues(alpha: 0.22);
    final borderWidth = isHighContrast ? 2.0 : 1.0;
    final activeBackgroundColor = isHighContrast
        ? colorScheme.primary
        : colorScheme.primary.withValues(alpha: 0.12);
    final activeForegroundColor =
        isHighContrast ? colorScheme.onPrimary : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 1. A search field that expands to fill the available space
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: TextField(
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: defaultBorderColor,
                      width: borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: isHighContrast ? 2 : 1.2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: defaultBorderColor,
                      width: borderWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. `Filter` button that opens a filter panel when tapped
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 148),
            child: GestureDetector(
              onTap: onFilterTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isFilterActive
                      ? activeBackgroundColor
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHighContrast
                        ? colorScheme.outline
                        : colorScheme.primary
                            .withValues(alpha: isFilterActive ? 0.28 : 0.10),
                    width: borderWidth,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 20,
                      color: isFilterActive
                          ? activeForegroundColor
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.22,
                      ),
                      child: Text(
                        l10n.filter,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isFilterActive
                              ? activeForegroundColor
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. A toggle button that switches between grid and list views of the search results
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: defaultBorderColor, width: borderWidth),
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.primary,
              ),
              onPressed: onToggleView,
              child: Icon(
                isGridView ? Icons.grid_view : Icons.view_list,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
