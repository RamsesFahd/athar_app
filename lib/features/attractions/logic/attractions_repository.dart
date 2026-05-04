import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';

final attractionsRepositoryProvider = Provider<AttractionsRepository>((ref) {
  return AttractionsRepository(FirebaseFirestore.instance);
});

final attractionsStreamProvider = StreamProvider<List<AttractionModel>>((ref) {
  return ref.read(attractionsRepositoryProvider).watchAttractions();
});

class AttractionsRepository {
  final FirebaseFirestore _firestore;

  AttractionsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _attractions =>
      _firestore.collection('attractions');

  Stream<List<AttractionModel>> watchAttractions() {
    return _attractions.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AttractionModel.fromMap(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  Stream<List<AttractionModel>> watchAttractionsByRegion(String region) {
    return _attractions
        .where('region', isEqualTo: region)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AttractionModel.fromMap(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  Stream<List<AttractionModel>> watchAttractionsByCategory(String category) {
    return _attractions
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AttractionModel.fromMap(doc.data(), doc.id),
              )
              .toList(),
        );
  }
}
