import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/core/widgets/storage_asset_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cultural_archive/widgets/cultural_item_card.dart';
import '../logic/cultural_notifier.dart';

class CulturalArchive extends ConsumerWidget {
  final VoidCallback? onBack;
  const CulturalArchive({super.key, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHighContrast = theme.isHighContrast;
    final l10n = AppLocalizations.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1.0) > 1.2;
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

    final viewMode = ref.watch(viewModeProvider);
    final showFilters = ref.watch(showFiltersProvider);

    final filteredItemsAsync = ref.watch(culturalNotifierProvider);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildHeader(isAr, theme, l10n, context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: TextField(
                      onChanged: (val) => ref
                          .read(culturalNotifierProvider.notifier)
                          .setSearchQuery(val),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        hintStyle: theme.textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        prefixIcon:
                            Icon(Icons.search, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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

                GestureDetector(
                  onTap: () => ref.read(showFiltersProvider.notifier).state =
                      !showFilters,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: showFilters
                          ? activeBackgroundColor
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHighContrast
                            ? colorScheme.outline
                            : colorScheme.primary.withValues(
                                alpha: showFilters ? 0.28 : 0.10,
                              ),
                        width: borderWidth,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune,
                          size: 20,
                          color: showFilters
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
                              color: showFilters
                                  ? activeForegroundColor
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(
                        color: defaultBorderColor,
                        width: borderWidth,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => ref.read(viewModeProvider.notifier).state =
                        viewMode == CardLayout.horizontal
                            ? CardLayout.vertical
                            : CardLayout.horizontal,
                    child: Icon(
                      viewMode == CardLayout.horizontal
                          ? Icons.grid_view
                          : Icons.view_list,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
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
                      : _buildGridView(filteredItems.filteredItems, largeText),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  Center(child: Text(l10n.commonErrorWithMessage(''))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isAr, ThemeData theme, AppLocalizations l10n, BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 230),
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(
            child: StorageAssetImage(
              storagePath: 'static/cultural_archive/header.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8)
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
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: isAr ? 1.4 : 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onBack != null)
            SafeArea(
              child: Align(
                alignment: isAr ? Alignment.topRight : Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(
      ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    final activeCategory = ref.watch(activeCategoryProvider);

    final categories = [
      ('all', l10n.filterAll),
      ('food', l10n.cat_food),
      ('craft', l10n.cat_craft),
      ('dance', l10n.cat_dance),
      ('architecture', l10n.cat_architecture),
      ('music', l10n.cat_music),
      ('clothing', l10n.cat_clothing),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories.map((cat) {
          final id = cat.$1;
          final label = cat.$2;
          final isSelected = activeCategory == id;

          return GestureDetector(
            onTap: () {
              ref.read(activeCategoryProvider.notifier).state = id;
              ref.read(culturalNotifierProvider.notifier).setCategory(id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
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
      cacheExtent: 600,
      itemBuilder: (context, index) =>
          _buildCard(context, filteredItems[index], CardLayout.horizontal),
    );
  }

  Widget _buildGridView(List filteredItems, bool largeText) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      cacheExtent: 600,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: largeText ? 0.68 : 0.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) =>
          _buildCard(context, filteredItems[index], CardLayout.vertical),
    );
  }

  Widget _buildCard(BuildContext context, item, CardLayout layout) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return RepaintBoundary(
      child: CulturalItemCard(
        id: item.id,
        item: item,
        title: isAr ? item.titleAr : item.titleEn,
        description: isAr ? item.descriptionAr : item.descriptionEn,
        imageUrl: item.imageUrl,
        categoryId: item.categoryId,
        region: isAr ? item.regionAr : item.regionEn,
        layout: layout,
      ),
    );
  }
}

