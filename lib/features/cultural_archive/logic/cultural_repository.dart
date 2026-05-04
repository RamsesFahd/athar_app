import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/cultural/category_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';


part 'cultural_repository.g.dart';


/// Riverpod Provider
@Riverpod(keepAlive: true) 
CulturalRepository culturalRepository(Ref ref) {
  return CulturalRepository(
    firestore: FirebaseFirestore.instance,
  );
}

///  Repository Class
class CulturalRepository {
  final FirebaseFirestore _firestore;
  List<CategoryModel>? _cachedCategories;
  List<CulturalItemModel>? _cachedItems;

  CulturalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection references
  CollectionReference get _categories =>
      _firestore.collection('categories');

  CollectionReference get _items =>
      _firestore.collection('cultural_items');

  // Fetches all categories with an in-memory caching 
  Future<List<CategoryModel>> fetchCategories() async {
    // 1. Return cached data if available to prevent redundant network requests.
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    final snapshot = await _categories.get();

    // 2. Map Firestore documents to CategoryModel and persist them in the local cache.
    _cachedCategories = snapshot.docs.map((doc) {
      return CategoryModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    return _cachedCategories!;
  }

  //Fetches all cultural items with memory caching 
  Future<List<CulturalItemModel>> fetchItems() async {
    // 1. Check if the items are already loaded in memory to avoid a network request.
    if (_cachedItems != null && _cachedItems!.isNotEmpty) {
      return _cachedItems!;
    }

    // 2. If the cache is empty, fetch data from the Firestore collection.
    final snapshot = await _items
      .orderBy('createdAt', descending: true) 
      .get();

    // 3. Map the documents to models and store them in the cache variable.
    _cachedItems = snapshot.docs.map((doc) {
      return CulturalItemModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    return _cachedItems!;
  }

  // Fetch items by category (efficient query)
  Future<List<CulturalItemModel>> fetchItemsByCategory(String categoryId) async {
    // 1. Ensure all items are loaded in the cache by calling fetchItems() first.
    final allItems = await fetchItems();
    
    // 2. Filter the items locally from the cache instead of making a new Firestore request.
    final filtered = allItems.where((item) => item.categoryId == categoryId).toList();

    // 3. Apply sorting on the filtered local list.
    filtered.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));

    return filtered;
  }

  void clearCache() {
    _cachedItems = null;
    _cachedCategories = null;
  }

  //  Fetch single item details
  Future<CulturalItemModel?> fetchItemDetails(String itemId) async {
    final doc = await _items.doc(itemId).get();

    if (!doc.exists) return null;

    return CulturalItemModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  // Method for uploading cultural items
  Future<void> seedDatabase(List<Map<String, dynamic>> dataList) async {

    final batch = _firestore.batch();

    for (var data in dataList) {
      // create an empty doc in firestore
      final docRef = _items.doc(); 

      // adding items with creation info
      batch.set(docRef, {
        ...data,
        'createdAt': FieldValue.serverTimestamp(), // توقيت السيرفر
        'createdBy': 'Rimas Admin', // لتمييز الإضافة الإدارية
      });
    }

    // تنفيذ كل العمليات بضغطة واحدة
    await batch.commit();
}
Future<void> migrateRegionIds() async {
  // Mapping from old regionAr/regionEn values to the new regionId
  final Map<String, String> arToRegionId = {
    'المنطقة الوسطى': 'central_region',
    'نجد': 'central_region',
    'المنطقة الغربية': 'western_region',
    'الحجاز': 'western_region',
    'مكة المكرمة': 'western_region',
    'المدينة المنورة': 'western_region',
    'جدة': 'western_region',
    'الطائف': 'western_region',
    'المنطقة الشمالية': 'northern_region',
    'المنطقة الشرقية': 'eastern_region',
    'الأحساء': 'eastern_region',
    'المنطقة الجنوبية': 'southern_region',
    'عسير': 'southern_region',
    'جازان': 'southern_region',
    'نجران': 'southern_region',
    'الباحة': 'southern_region',
    'منطقة الباحة': 'southern_region',
    'الجوف': 'northern_region',
    'منطقة عسير': 'southern_region',
    'حائل': 'northern_region',
    'منطقة جازان': 'southern_region',
    'منطقة نجران': 'southern_region',
    'القصيم': 'central_region',
    'الرياض': 'central_region',
    'تبوك': 'northern_region',
  };

  final Map<String, String> enToRegionId = {
    'Central Region': 'central_region',
    'Najd': 'central_region',
    'Western Region': 'western_region',
    'Hejaz': 'western_region',
    'Makkah': 'western_region',
    'Madinah': 'western_region',
    'Jeddah': 'western_region',
    'Taif': 'western_region',
    'Northern Region': 'northern_region',
    'Eastern Region': 'eastern_region',
    'Al-Ahsa': 'eastern_region',
    'Southern Region': 'southern_region',
    'Asir': 'southern_region',
    'Jazan': 'southern_region',
    'Najran': 'southern_region',
    'Al Baha': 'southern_region',
    'Al Baha Region': 'southern_region',
    'Al-Jouf': 'northern_region',
    'Asir Region': 'southern_region',
    'Hail': 'northern_region',
    'Jazan Region': 'southern_region',
    'Najran Region': 'southern_region',
    'Qassim': 'central_region',
    'Riyadh': 'central_region',
    'Tabuk': 'northern_region',
  };

  var _items= FirebaseFirestore.instance.collection('cultural_items');
  final snapshot = await _items.get();
  var  _firestore = FirebaseFirestore.instance;
  final batch = _firestore.batch();
  int count = 0;

  for (final doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;

    // Skip if regionId already exists
    if (data['regionId'] != null && data['regionId'].toString().isNotEmpty) {
      continue;
    }

    final regionAr = data['regionAr']?.toString().trim() ?? '';
    final regionEn = data['regionEn']?.toString().trim() ?? '';

    // Try to find matching regionId
    final regionId = arToRegionId[regionAr] ?? enToRegionId[regionEn] ?? '';

    if (regionId.isEmpty) {
      print('⚠️ No match found for doc: ${doc.id} | regionAr: $regionAr | regionEn: $regionEn');
      continue;
    }

    batch.update(doc.reference, {'regionId': regionId});
    count++;
    print('✅ Queued: ${doc.id} → $regionId');
  }

  await batch.commit();
  print('🎉 Migration done. Updated $count documents.');
}
}

