import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';
import '../../cultural_archive/widgets/cultural_item_card.dart';


part 'cultural_notifier.g.dart';

@Riverpod(keepAlive: true)
class CulturalNotifier extends _$CulturalNotifier {
  @override
  FutureOr<CulturalState> build() async {
    return _loadItems();
  }

  /// Load items from Firestore
  Future<CulturalState> _loadItems() async {
    // reactive reference to the repository to ensure state synchronization.
    final repo = ref.watch(culturalRepositoryProvider);
    final items = await repo.fetchItems();

    return CulturalState(
      allItems: items,
      filteredItems: items,
      searchQuery: '',
      activeCategory: 'all',
      isLoading: false,
    );
  }

  CulturalItemModel? findItemByTitle(String title) {
  final current = state.value;
  if (current == null) return null;

  // تنظيف النص من المسافات الزائدة وتحويله لـ lowercase
  final String searchKey = title.trim().toLowerCase();

  try {
    return current.allItems.firstWhere(
      (item) {
        final String titleAr = item.titleAr.trim().toLowerCase();
        final String titleEn = item.titleEn.trim().toLowerCase();
        
        // مقارنة ذكية: هل أحدهما يحتوي على الآخر؟
        return titleAr.contains(searchKey) || 
               searchKey.contains(titleAr) || 
               titleEn.contains(searchKey) || 
               searchKey.contains(titleEn);
      },
    );
  } catch (_) {
    return null; 
  }
}

  // Search
  void setSearchQuery(String query) {
    final current = state.value;
    if (current == null) return;

    final filtered = _applyFilters(
      current.allItems,
      query,
      current.activeCategory,
    );

    state = AsyncData(
      current.copyWith(
        searchQuery: query,
        filteredItems: filtered,
      ),
    );
  }

  // Category filter
  void setCategory(String categoryId) {
    final current = state.value;
    if (current == null) return;

    final filtered = _applyFilters(
      current.allItems,
      current.searchQuery,
      categoryId,
    );

    state = AsyncData(
      current.copyWith(
        activeCategory: categoryId,
        filteredItems: filtered,
      ),
    );
  }

  // Filtering logic
  List<CulturalItemModel> _applyFilters(
    List<CulturalItemModel> items,
    String search,
    String category,
  ) {
    return items.where((item) {
      final matchesSearch = search.isEmpty ||
          item.titleEn.toLowerCase().contains(search.toLowerCase()) ||
          item.titleAr.contains(search);

      final matchesCategory =
          category == 'all' || item.categoryId == category;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<CulturalItemModel> getItemsByRegion(String regionId) {
    final current = state.valueOrNull;
    if (current == null) return [];
    return current.allItems
        .where((item) => item.regionId == regionId)
        .toList();
  }
}

// Providers
  final categoriesProvider = FutureProvider((ref) async {
  // Using watch to maintain synchronization with the repository's internal state.
  final repo = ref.watch(culturalRepositoryProvider);
  return repo.fetchCategories();
});

final filteredItemsProvider = Provider((ref) {
  final stateAsync = ref.watch(culturalNotifierProvider);
  return stateAsync.value?.filteredItems ?? [];
});

final viewModeProvider =
    StateProvider<CardLayout>((ref) => CardLayout.horizontal);

final showFiltersProvider =
    StateProvider<bool>((ref) => false);

final activeCategoryProvider =
    StateProvider<String>((ref) => 'all');


//كود الحالة ممكن اخليه في ملف خارجي

class CulturalState {
  final List<CulturalItemModel> allItems;
  final List<CulturalItemModel> filteredItems;
  final String searchQuery;
  final String activeCategory;
  final bool isLoading;

  CulturalState({
    required this.allItems,
    required this.filteredItems,
    required this.searchQuery,
    required this.activeCategory,
    required this.isLoading,
  });

  factory CulturalState.initial() => CulturalState(
        allItems: [],
        filteredItems: [],
        searchQuery: '',
        activeCategory: 'all',
        isLoading: true,
      );

  CulturalState copyWith({
    List<CulturalItemModel>? allItems,
    List<CulturalItemModel>? filteredItems,
    String? searchQuery,
    String? activeCategory,
    bool? isLoading,
  }) {
    return CulturalState(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }


}
