import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:athar_app/core/models/cultural/category_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';

class MockCulturalRepository extends Mock implements CulturalRepository {}

CulturalItemModel makeCulturalItem({
  required String id,
  required String titleEn,
  String titleAr = 'Title Ar',
  String categoryId = 'food',
  String regionId = 'central',
  DateTime? createdAt,
}) {
  return CulturalItemModel(
    id: id,
    titleAr: titleAr,
    titleEn: titleEn,
    descriptionAr: '',
    descriptionEn: '',
    imageUrl: '',
    categoryId: categoryId,
    regionId: regionId,
    regionEn: regionId,
    regionAr: regionId,
    createdAt: createdAt,
  );
}

void main() {
  group('CulturalState', () {
    test('UT-75: initial state starts loading with empty filters', () {
      final state = CulturalState.initial();

      expect(state.allItems, isEmpty);
      expect(state.filteredItems, isEmpty);
      expect(state.searchQuery, '');
      expect(state.activeCategory, 'all');
      expect(state.isLoading, isTrue);
    });

    test('UT-76: copyWith modifies only specified fields', () {
      final original = CulturalState.initial();
      final item = makeCulturalItem(id: 'i1', titleEn: 'Coffee');

      final updated = original.copyWith(
        allItems: [item],
        isLoading: false,
      );

      expect(updated.allItems, [item]);
      expect(updated.filteredItems, original.filteredItems);
      expect(updated.searchQuery, original.searchQuery);
      expect(updated.activeCategory, original.activeCategory);
      expect(updated.isLoading, isFalse);
    });
  });

  group('CulturalNotifier', () {
    late MockCulturalRepository repo;
    late ProviderContainer container;

    final items = [
      makeCulturalItem(
        id: 'i1',
        titleEn: 'Saudi Coffee',
        titleAr: 'Coffee Ar',
        categoryId: 'food',
        regionId: 'central',
      ),
      makeCulturalItem(
        id: 'i2',
        titleEn: 'Palm Craft',
        titleAr: 'Craft Ar',
        categoryId: 'craft',
        regionId: 'western',
      ),
    ];

    setUp(() {
      repo = MockCulturalRepository();
      when(() => repo.fetchItems()).thenAnswer((_) async => items);
      when(() => repo.fetchCategories()).thenAnswer(
        (_) async => [
          CategoryModel(id: 'food', nameAr: 'Food Ar', nameEn: 'Food'),
        ],
      );
      container = ProviderContainer(
        overrides: [
          culturalRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('UT-77: build loads all items and mirrors them into filteredItems',
        () async {
      final state = await container.read(culturalNotifierProvider.future);

      expect(state.allItems.length, 2);
      expect(state.filteredItems.length, 2);
      expect(state.activeCategory, 'all');
      expect(state.isLoading, isFalse);
      verify(() => repo.fetchItems()).called(1);
    });

    test('UT-78: setSearchQuery filters items by English title', () async {
      await container.read(culturalNotifierProvider.future);

      container
          .read(culturalNotifierProvider.notifier)
          .setSearchQuery('coffee');

      final state = container.read(culturalNotifierProvider).value!;

      expect(state.searchQuery, 'coffee');
      expect(state.filteredItems.map((item) => item.id).toList(), ['i1']);
    });

    test('UT-79: setCategory filters items by categoryId', () async {
      await container.read(culturalNotifierProvider.future);

      container.read(culturalNotifierProvider.notifier).setCategory('craft');

      final state = container.read(culturalNotifierProvider).value!;

      expect(state.activeCategory, 'craft');
      expect(state.filteredItems.map((item) => item.id).toList(), ['i2']);
    });

    test('UT-80: findItemByTitle matches trimmed case-insensitive title',
        () async {
      await container.read(culturalNotifierProvider.future);

      final match = container
          .read(culturalNotifierProvider.notifier)
          .findItemByTitle('  saudi coffee  ');

      expect(match?.id, 'i1');
    });

    test('UT-81: getItemsByRegion returns only matching region items',
        () async {
      await container.read(culturalNotifierProvider.future);

      final result = container
          .read(culturalNotifierProvider.notifier)
          .getItemsByRegion('western');

      expect(result.map((item) => item.id).toList(), ['i2']);
    });
  });
}
