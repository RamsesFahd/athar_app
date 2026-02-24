import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cultural_archive/widgets/cultural_item_card.dart';
import '../../../core/widgets/search_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/cultural_notifier.dart';

class CulturalArchive extends ConsumerWidget {
  const CulturalArchive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final viewMode = ref.watch(viewModeProvider);
    final showFilters = ref.watch(showFiltersProvider);

    final filteredItemsAsync = ref.watch(culturalNotifierProvider);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildHeader(isAr, theme, l10n),
          
          CustomSearchBar(
            hintText: l10n.searchHint,
            isGridView: viewMode == CardLayout.vertical,
            onChanged: (val) =>
                ref.read(culturalNotifierProvider.notifier).setSearchQuery(val),
            onFilterTap: () =>
                ref.read(showFiltersProvider.notifier).state = !showFilters,
            onToggleView: () =>
                ref.read(viewModeProvider.notifier).state =
                viewMode == CardLayout.horizontal
                    ? CardLayout.vertical
                    : CardLayout.horizontal,
          ),
          if (showFilters) _buildFiltersSection(theme, l10n, ref),
          Expanded(
            child: filteredItemsAsync.when(
              data: (filteredItems) => filteredItems.filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        isAr ? 'لم يتم العثور على نتائج' : 'No items found',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : viewMode == CardLayout.horizontal
                      ? _buildListView(filteredItems.filteredItems)
                      : _buildGridView(filteredItems.filteredItems),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Error loading items')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isAr, ThemeData theme, AppLocalizations l10n) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cultural_archive_header.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha:0.3),
              Colors.black.withValues(alpha:0.8)
            ],
          ),
        ),
        alignment: isAr ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.culturalArchiveTitle,
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white,
                height: isAr ? 1.4 : 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? 'اكتشف الثقافة السعودية الغنية'
                  : 'Discover Saudi heritage',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha:0.8),
                height: isAr ? 1.4 : 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    final activeCategory = ref.watch(activeCategoryProvider);

    final Map<String, String> categories = {
      'all': l10n.filterAll,
      'food': l10n.cat_food,
      'craft': l10n.cat_craft,
      'dance': l10n.cat_dance,
      'architecture': l10n.cat_architecture,
      'music': l10n.cat_music,
      'clothing': l10n.cat_clothing,
    };

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.entries.map((entry) {
          final isSelected = activeCategory == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) {
                  ref.read(activeCategoryProvider.notifier).state = entry.key;
                  ref.read(culturalNotifierProvider.notifier).setCategory(entry.key);
              },
              selectedColor: AppColors.secondary.withValues(alpha:0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.sage900,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                height: 1.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListView(List filteredItems) {
    return ListView.builder(
      itemCount: filteredItems.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) =>
          _buildCard(context, filteredItems[index], CardLayout.horizontal),
    );
  }

  Widget _buildGridView(List filteredItems) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) =>
          _buildCard(context, filteredItems[index], CardLayout.vertical),
    );
  }

  Widget _buildCard(BuildContext context,item, CardLayout layout) {
    final bool isAr =
        Localizations.localeOf(context).languageCode == 'ar';

    return CulturalItemCard(
      id: item.id,
      item: item,
      title: isAr ? item.titleAr : item.titleEn,
      description: isAr
          ? item.descriptionAr
          : item.descriptionEn,
      imageUrl: item.imageUrl,
      categoryId: item.categoryId,
      region: isAr
          ? item.regionAr
          : item.regionEn,
      layout: layout,
    );
  }
}

//dart run build_runner build --delete-conflicting-outputs