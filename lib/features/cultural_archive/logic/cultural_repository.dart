import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/user/cultural/category_model.dart';
import 'package:athar_app/core/models/user/cultural/cultural_item_model.dart';


part 'cultural_repository.g.dart';

///  Riverpod Provider
@riverpod
CulturalRepository culturalRepository(Ref ref) {
  return CulturalRepository(
    firestore: FirebaseFirestore.instance,
  );
}

///  Repository Class
class CulturalRepository {
  final FirebaseFirestore _firestore;

  CulturalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection references
  CollectionReference get _categories =>
      _firestore.collection('categories');

  CollectionReference get _items =>
      _firestore.collection('cultural_items');

  // Fetch all categories
  Future<List<CategoryModel>> fetchCategories() async {
    final snapshot = await _categories.get();

    return snapshot.docs.map((doc) {
      return CategoryModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Fetch all cultural items
  Future<List<CulturalItemModel>> fetchItems() async {
    final snapshot = await _items.get();

    return snapshot.docs.map((doc) {
      return CulturalItemModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Fetch items by category (efficient query)
  Future<List<CulturalItemModel>> fetchItemsByCategory(
      String categoryId) async {
    final snapshot = await _items
        .where('categoryId', isEqualTo: categoryId)
        .get();

    return snapshot.docs.map((doc) {
      return CulturalItemModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
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
}