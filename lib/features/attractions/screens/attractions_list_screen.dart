import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/attractions/widgets/attraction_card.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/theme/app_theme.dart';

class AttractionsListScreen extends ConsumerStatefulWidget {
  const AttractionsListScreen({super.key});

  @override
  ConsumerState<AttractionsListScreen> createState() =>
      _AttractionsListScreenState();
}

class _AttractionsListScreenState extends ConsumerState<AttractionsListScreen> {
  bool _isGridView = true;
  bool _showFilters = false;
  String _selectedRegion = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // PERFORMANCE OPTIMIZATION: Cached derivations from stream data.
  // Updated via ref.listen only when Firestore emits a new snapshot,
  // not on every setState (search keystrokes, filter toggles, grid toggle).
  List<AttractionModel> _allItems = const [];
  List<String> _regions = const ['All'];
  List<String> _categories = const ['All'];
  Map<String, Color> _categoryColors = const {};

  static Color _hexColor(String code) {
    final n = code.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$n', radix: 16));
  }

  @override
  void initState() {
    super.initState();
    // Seed from the already-emitted value so the list is never blank on back
    // navigation (the stream may have emitted before this widget mounted).
    ref.read(attractionsStreamProvider).whenData(_updateCache);
    // ref.listenManual is the correct API for initState; ref.listen is build()-only.
    ref.listenManual(attractionsStreamProvider, (_, next) {
      next.whenData(_updateCache);
    });
  }

  void _updateCache(List<AttractionModel> items) {
    // Called from initState seed (no setState needed — first build hasn't run)
    // and from listenManual (ref.watch in build triggers the rebuild, so
    // setState is also not needed for subsequent emissions).
    _allItems = items;
    _regions = [
      'All',
      ...{...items.map((i) => i.region)}
    ];
    _categories = [
      'All',
      ...{...items.map((i) => i.category)}
    ];
    _categoryColors = {
      for (final item in items)
        item.category: _hexColor(item.categoryColorCode),
    };
  }

  String _translateCategory(String value, bool isAr) {
    if (!isAr) return value;

    switch (value.toLowerCase()) {
      case 'heritage':
        return 'تراث';
      case 'nature':
        return 'طبيعة';
      case 'arts':
        return 'فنون';
      case 'modern':
        return 'عصري';
      case 'all':
        return 'الكل';
      default:
        return value;
    }
  }

  String _translateRegion(String value, bool isAr) {
    if (!isAr) return value;

    switch (value.toLowerCase()) {
      case 'central_region':
        return 'المنطقة الوسطى';
      case 'northern_region':
        return 'المنطقة الشمالية';
      case 'western_region':
        return 'المنطقة الغربية';
      case 'southern_region':
        return 'المنطقة الجنوبية';
      case 'eastern_region':
        return 'المنطقة الشرقية';
      case 'all':
        return 'الكل';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final attractionsAsync = ref.watch(attractionsStreamProvider);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final largeText = textScale > 1.2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.attractionsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: attractionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) {
          // Use pre-cached collections. Only the filter pass runs here,
          // which is an O(n) scan — not the O(n) set/map allocations.
          final filtered = _allItems.where((item) {
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
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: l10n.attractionsSearchHint,
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _isGridView = !_isGridView),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                          backgroundColor: theme.colorScheme.surface,
                        ),
                        child: Icon(
                          _isGridView ? Icons.grid_view : Icons.view_list,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _showFilters = !_showFilters),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: _showFilters
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.7)
                                : theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                          ),
                          backgroundColor: _showFilters
                              ? theme.colorScheme.primary
                                  .withValues(alpha: 0.08)
                              : theme.colorScheme.surface,
                        ),
                        child: Icon(
                          Icons.tune,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showFilters) ...[
                const SizedBox(height: 12),
                _FilterRow(
                  label: l10n.locationLabel,
                  options: _regions,
                  selected: _selectedRegion,
                  onSelected: (v) => setState(() => _selectedRegion = v),
                  allLabel: l10n.filterAll,
                  labelFor: (v) => _translateRegion(v, isAr),
                ),
                const SizedBox(height: 6),
                _FilterRow(
                  label: l10n.categoryLabel,
                  options: _categories,
                  selected: _selectedCategory,
                  onSelected: (v) => setState(() => _selectedCategory = v),
                  allLabel: l10n.filterAll,
                  colorFor: (v) => v == 'All' ? null : _categoryColors[v],
                  labelFor: (v) => _translateCategory(v, isAr),
                ),
              ],
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _allItems.isEmpty
                          ? l10n.attractionsNoAvailable
                          : l10n.attractionsNoResults,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 12,
                            childAspectRatio: largeText ? 0.62 : 0.72,
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
  final String allLabel;
  final Color? Function(String)? colorFor;
  final String Function(String)? labelFor;

  const _FilterRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.allLabel,
    this.colorFor,
    this.labelFor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final rowExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 18).toDouble();
    return SizedBox(
      height: 40 + rowExtra,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = options[index];
          final isSelected = value == selected;
          final accent = theme.isHighContrast
              ? theme.colorScheme.primary
              : colorFor?.call(value) ?? theme.colorScheme.primary;

          return GestureDetector(
            onTap: () => onSelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accent
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                labelFor?.call(value) ?? (value == 'All' ? allLabel : value),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
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
