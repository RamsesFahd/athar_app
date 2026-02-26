import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onToggleView;
  final bool isGridView;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    required this.onToggleView,
    required this.isGridView,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // حقل البحث (أخذ أكبر مساحة ممكنة)
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // زر الفلتر مع الكلمة (زي المتصفح)
          OutlinedButton.icon(
            onPressed: onFilterTap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: Icon(Icons.tune, size: 20, color: AppColors.primary),
            label: const Text(
              "Filter",
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),

          const SizedBox(width: 8),

          // أزرار العرض مفصلة (قائمة وشبكة)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.grid_view,
                    size: 20,
                    color: isGridView ? AppColors.primary : Colors.grey,
                  ),
                  onPressed: isGridView ? null : onToggleView,
                ),
                VerticalDivider(
                    width: 1, thickness: 1, color: Colors.grey.shade300),
                IconButton(
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.view_list,
                    size: 20,
                    color: !isGridView ? AppColors.primary : Colors.grey,
                  ),
                  onPressed: !isGridView ? null : onToggleView,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}