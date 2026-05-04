import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/favorites/favorite_item_model.dart';

part 'favorites_repository.g.dart';

@riverpod
FavoritesRepository favoritesRepository(Ref ref) {
  return FavoritesRepository(firestore: FirebaseFirestore.instance);
}

class FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  Stream<List<FavoriteItemModel>> watchFavorites(String uid) {
    return _col(uid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => FavoriteItemModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  Future<bool> isFavorite(String uid, String itemId) async {
    final doc = await _col(uid).doc(itemId).get();
    return doc.exists;
  }

  Future<void> addFavorite(String uid, FavoriteItemModel item) async {
    await _col(uid).doc(item.itemId).set(item.toMap());
  }

  Future<void> removeFavorite(String uid, String itemId) async {
    await _col(uid).doc(itemId).delete();
  }

  Future<bool> toggleFavorite(String uid, FavoriteItemModel item) async {
    final exists = await isFavorite(uid, item.itemId);
    if (exists) {
      await removeFavorite(uid, item.itemId);
      return false;
    } else {
      await addFavorite(uid, item);
      return true;
    }
  }
}
