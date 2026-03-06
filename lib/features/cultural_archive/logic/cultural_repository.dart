import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/user/cultural/category_model.dart';
import 'package:athar_app/core/models/user/cultural/cultural_item_model.dart';


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
}
