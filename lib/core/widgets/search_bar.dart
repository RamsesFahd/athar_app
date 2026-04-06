import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
        final l10n = AppLocalizations.of(context);

    // these colors are used for the borders of the search field in different states, ensuring a consistent and visually appealing design across the app
    final defaultBorderColor = theme.colorScheme.outline.withValues(alpha: 0.3);
    final focusedBorderColor = theme.colorScheme.primary.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 1. A search field that expands to fill the available space
          Expanded(
            child: SizedBox(
              height: 44, 
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.sage800.withValues(alpha: 0.4), 
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  
                  
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: defaultBorderColor,
                      width: 1.0, 
                    ),
                  ),
                  
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 1.5, 
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),

          // 2. `Filter` button that opens a filter panel when tapped
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isFilterActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFilterActive ? AppColors.primary : defaultBorderColor,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 20,
                    color: isFilterActive ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.filter,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isFilterActive ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. A toggle button that switches between grid and list views of the search results
          SizedBox(
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: defaultBorderColor, width: 1.0),
                backgroundColor: AppColors.surface,
              ),
              onPressed: onToggleView,
              child: Icon(
                isGridView ? Icons.grid_view : Icons.view_list,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}