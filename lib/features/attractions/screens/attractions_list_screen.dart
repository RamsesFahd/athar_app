import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/attractions/widgets/attraction_card.dart';

class AttractionsListScreen extends ConsumerStatefulWidget {
  const AttractionsListScreen({super.key});

  @override
  ConsumerState<AttractionsListScreen> createState() =>
      _AttractionsListScreenState();
}

class _AttractionsListScreenState
    extends ConsumerState<AttractionsListScreen> {
  bool _isGridView = true;
  bool _showFilters = false;
  String _selectedRegion = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  static Color _hexColor(String code) {
    final n = code.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$n', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final attractionsAsync = ref.watch(attractionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'المعالم السياحية' : 'Attractions',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: attractionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          final regions = ['All', ...{...items.map((i) => i.region)}];
          final categories = ['All', ...{...items.map((i) => i.category)}];

          final categoryColors = <String, Color>{
            for (final item in items)
              item.category: _hexColor(item.categoryColorCode),
          };

          final filtered = items.where((item) {
            final matchRegion =
                _selectedRegion == 'All' || item.region == _selectedRegion;
            final matchCat = _selectedCategory == 'All' ||
                item.category == _selectedCategory;
            final q = _searchQuery.toLowerCase();
            final matchSearch = q.isEmpty ||
                item.getName(isAr).toLowerCase().contains(q) ||
                item.getCity(true).toLowerCase().contains(q) ||
                    item.getCity(false).toLowerCase().contains(q);
            return matchRegion && matchCat && matchSearch;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: isAr
                                ? 'ابحث عن معلم سياحي...'
                                : 'Search attractions...',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      AppColors.sage800.withValues(alpha: 0.4),
                                ),
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.primary),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    AppColors.primary.withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _isGridView = !_isGridView),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Icon(
                          _isGridView ? Icons.grid_view : Icons.view_list,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _showFilters = !_showFilters),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: _showFilters
                                ? AppColors.primary.withValues(alpha: 0.7)
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3),
                          ),
                          backgroundColor: _showFilters
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                        ),
                        child: Icon(
                          Icons.tune,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showFilters) ...[
                const SizedBox(height: 12),
                _FilterRow(
                  label: isAr ? 'المنطقة' : 'Region',
                  options: regions,
                  selected: _selectedRegion,
                  onSelected: (v) => setState(() => _selectedRegion = v),
                  isAr: isAr,
                ),
                const SizedBox(height: 6),
                _FilterRow(
                  label: isAr ? 'التصنيف' : 'Category',
                  options: categories,
                  selected: _selectedCategory,
                  onSelected: (v) => setState(() => _selectedCategory = v),
                  isAr: isAr,
                  colorFor: (v) => v == 'All' ? null : categoryColors[v],
                ),
              ],
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      items.isEmpty
                          ? (isAr
                              ? 'لا توجد معالم سياحية'
                              : 'No attractions available')
                          : (isAr ? 'لا توجد نتائج' : 'No results found'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                Expanded(
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => AttractionCard(
                            attraction: filtered[index],
                            isGridView: true,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => AttractionCard(
                            attraction: filtered[index],
                            isGridView: false,
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isAr;
  final Color? Function(String)? colorFor;

  const _FilterRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.isAr,
    this.colorFor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = options[index];
          final isSelected = value == selected;
          final accent =
              colorFor?.call(value) ?? Theme.of(context).colorScheme.primary;

          return GestureDetector(
            onTap: () => onSelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accent
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                value == 'All' ? (isAr ? 'الكل' : 'All') : value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : AppColors.sage800,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
