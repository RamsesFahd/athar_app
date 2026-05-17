// ============================================================================
// Athar — Taxonomy Repository
// ----------------------------------------------------------------------------
// Location: lib/core/utils/taxonomy_repository.dart
//
// Responsibility: Reads the /taxonomy collection from Firestore and exposes it
// as a typed, cached, Riverpod-friendly stream.
//
// Why a repository (not direct Firestore calls in the widget):
//   - The taxonomy rarely changes (15 docs, maybe edited once a month by admin)
//     so we cache it in memory after first read
//   - Multiple screens need it (onboarding, profile→my interests, Rawi, banners)
//   - Future-proofs: if we ever switch storage, only this file changes
//
// Usage:
//   final taxonomyAsync = ref.watch(taxonomyProvider);
//   taxonomyAsync.when(
//     data: (interests) => /* render */,
//     loading: () => CircularProgressIndicator(),
//     error: (err, _) => Text('Error: $err'),
//   );
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// Model
// ============================================================================

/// Represents one user-facing interest from the /taxonomy collection.
class TaxonomyInterest {
  final String id;              // e.g., 'heritage_sites' (stable, used in queries)
  final String labelAr;
  final String labelEn;
  final String imageUrl;        // Firebase Storage path, e.g., 'taxonomy/heritage_sites.webp'
  final String icon;            // emoji
  final String category;        // one of: architecture, clothing, craft, dance, food, music, general
  final List<String> synonyms;
  final List<String> relatedInterests;
  final List<String> appliesTo; // content collections this interest filters
  final int displayOrder;
  final bool isActive;

  const TaxonomyInterest({
    required this.id,
    required this.labelAr,
    required this.labelEn,
    required this.imageUrl,
    required this.icon,
    required this.category,
    required this.synonyms,
    required this.relatedInterests,
    required this.appliesTo,
    required this.displayOrder,
    required this.isActive,
  });

  /// Returns the label in the given locale (defaults to Arabic).
  String label(String locale) => locale == 'en' ? labelEn : labelAr;

  factory TaxonomyInterest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final labelMap = (data['label'] as Map?) ?? {};

    return TaxonomyInterest(
      id: data['id'] as String? ?? doc.id,
      labelAr: labelMap['ar'] as String? ?? '',
      labelEn: labelMap['en'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      icon: data['icon'] as String? ?? '',
      category: data['category'] as String? ?? 'general',
      synonyms: List<String>.from(data['synonyms'] ?? []),
      relatedInterests: List<String>.from(data['relatedInterests'] ?? []),
      appliesTo: List<String>.from(data['appliesTo'] ?? []),
      displayOrder: (data['displayOrder'] as num?)?.toInt() ?? 999,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}

// ============================================================================
// Repository
// ============================================================================

class TaxonomyRepository {
  final FirebaseFirestore _firestore;
  TaxonomyRepository(this._firestore);

  static const String _collection = 'taxonomy';

  /// Fetches all active interests sorted by displayOrder.
  /// Called once per app session (cached by the Riverpod provider below).
  Future<List<TaxonomyInterest>> fetchActiveInterests() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .get();

    return snapshot.docs
        .map((doc) => TaxonomyInterest.fromFirestore(doc))
        .toList();
  }

  /// Fetches a single interest by its ID. Useful for resolving stored
  /// user interests back into display objects.
  Future<TaxonomyInterest?> fetchById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return TaxonomyInterest.fromFirestore(doc);
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provides the singleton repository instance.
final taxonomyRepositoryProvider = Provider<TaxonomyRepository>((ref) {
  return TaxonomyRepository(FirebaseFirestore.instance);
});

/// Provides the cached list of all active interests.
/// Riverpod caches this for the lifetime of the app, so the network call
/// happens only once per session.
final taxonomyProvider = FutureProvider<List<TaxonomyInterest>>((ref) async {
  final repo = ref.watch(taxonomyRepositoryProvider);
  return repo.fetchActiveInterests();
});
