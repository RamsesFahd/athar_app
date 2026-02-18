import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../auth/widgets/cultural_item_card.dart';
import '../../../core/widgets/search_bar.dart';
import '../../../core/theme/app_colors.dart';

class CulturalArchive extends StatefulWidget {
  const CulturalArchive({super.key});

  @override
  State<CulturalArchive> createState() => _CulturalArchiveState();
}

class _CulturalArchiveState extends State<CulturalArchive> {
  String searchQuery = '';
  bool showFilters = false;
  CardLayout viewMode = CardLayout.horizontal;
  String activeCategory = 'all';

  final List<Map<String, dynamic>> culturalItems = [
    {
      'id': 'coffee',
      'image':
          'https://images.pexels.com/photos/1727123/pexels-photo-1727123.jpeg',
      'category': 'food',
      'region': 'riyadh'
    },
    {
      'id': 'sadu',
      'image':
          'https://images.pexels.com/photos/5505172/pexels-photo-5505172.jpeg',
      'category': 'craft',
      'region': 'riyadh'
    },
    {
      'id': 'kleija',
      'image':
          'https://images.pexels.com/photos/15632126/pexels-photo-15632126.jpeg',
      'category': 'food',
      'region': 'qassim'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final filteredItems = culturalItems.where((item) {
      String itemTitle = '';
      if (item['id'] == 'coffee') itemTitle = loc.coffeeTitle;
      if (item['id'] == 'sadu') itemTitle = loc.saduTitle;
      if (item['id'] == 'kleija') itemTitle = loc.kleijaTitle;

      final matchesSearch = searchQuery.isEmpty ||
          itemTitle.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCategory = activeCategory == 'all' ||
          item['category'].toString().toLowerCase() ==
              activeCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildHeader(isAr, theme, loc),
          CustomSearchBar(
            hintText: loc.searchHint,
            isGridView: viewMode == CardLayout.vertical,
            onChanged: (val) => setState(() => searchQuery = val),
            onFilterTap: () => setState(() => showFilters = !showFilters),
            onToggleView: () => setState(() {
              viewMode = (viewMode == CardLayout.horizontal)
                  ? CardLayout.vertical
                  : CardLayout.horizontal;
            }),
          ),
          if (showFilters) _buildFiltersSection(theme, loc),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      isAr ? 'لم يتم العثور على نتائج' : 'No items found',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : viewMode == CardLayout.horizontal
                    ? _buildListView(filteredItems)
                    : _buildGridView(filteredItems),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isAr, ThemeData theme, AppLocalizations loc) {
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
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.8)
            ],
          ),
        ),
        alignment: isAr ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.culturalArchiveTitle,
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
                color: Colors.white.withOpacity(0.8),
                height: isAr ? 1.4 : 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme, AppLocalizations loc) {
    final Map<String, String> categories = {
      'all': loc.filterAll,
      'food': loc.cat_food,
      'craft': loc.cat_craft,
      'dance': loc.cat_dance,
      'architecture': loc.cat_architecture,
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
              onSelected: (_) => setState(() => activeCategory = entry.key),
              selectedColor: AppColors.secondary.withOpacity(0.2),
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
          _buildCard(filteredItems[index], CardLayout.horizontal),
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
          _buildCard(filteredItems[index], CardLayout.vertical),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, CardLayout layout) {
    return CulturalItemCard(
      id: item['id'],
      image: item['image'],
      category: item['category'],
      region: item['region'],
      layout: layout,
    );
  }
}
