import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';
part 'admin_repository.g.dart';

@riverpod
AdminRepository adminRepository(Ref ref) {
  return AdminRepository();
}

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _trips => _firestore.collection('trips');
  CollectionReference get _bookings => _firestore.collection('bookings');
  CollectionReference get _culturalItems =>
      _firestore.collection('cultural_items');

  // ── Tutor Verification ──────────────────────────────────────────────────────

  Stream<List<TutorModel>> getPendingTutors() {
    return _users
        .where('role', isEqualTo: UserRole.tutor.name)
        .where('verificationStatus', isEqualTo: VerificationStatus.pending.name)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                TutorModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> approveTutor(
    String uId, {
    required String adminId,
    required String adminName,
  }) async {
    await _users.doc(uId).update({
      'verificationStatus': VerificationStatus.verified.name,
      'verifiedByAdminId': adminId,
      'verifiedByAdminName': adminName,
      'verificationActionAt': Timestamp.now(),
      'rejectionReason': null,
    });
  }

  Future<void> rejectTutor(
    String uId, {
    required String adminId,
    required String adminName,
    required String reason,
  }) async {
    await _users.doc(uId).update({
      'verificationStatus': VerificationStatus.rejected.name,
      'verifiedByAdminId': adminId,
      'verifiedByAdminName': adminName,
      'verificationActionAt': Timestamp.now(),
      'rejectionReason': reason,
    });
  }

  Stream<List<TutorModel>> getAllTutors() {
    return _users
        .where('role', isEqualTo: UserRole.tutor.name)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                TutorModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ── Trip Approvals ──────────────────────────────────────────────────────────

  Stream<List<TripModel>> getPendingTrips() {
    return _trips
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TripModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<TripModel>> getAllTrips() {
    return _trips
        .orderBy('status')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TripModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> approveTrip(
    String tripId, {
    required String tutorId,
    required String adminId,
    required String adminName,
  }) async {
    await _trips.doc(tripId).update({
      'status': 'approved',
      'reviewedByAdminId': adminId,
      'reviewedByAdminName': adminName,
      'reviewedAt': Timestamp.now(),
      'rejectionReason': null,
    });
  }

  Future<void> rejectTrip(
    String tripId, {
    required String tutorId,
    required String adminId,
    required String adminName,
    required String reason,
  }) async {
    await _trips.doc(tripId).update({
      'status': 'rejected',
      'reviewedByAdminId': adminId,
      'reviewedByAdminName': adminName,
      'reviewedAt': Timestamp.now(),
      'rejectionReason': reason,
    });
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ── Users Management ────────────────────────────────────────────────────────

  Stream<List<UserModel>> getAllUsers() {
    return _users
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ── All Bookings ─────────────────────────────────────────────────────────────

  Stream<List<BookingModel>> getAllBookings() {
    return _bookings
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                BookingModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ── Cultural Content ─────────────────────────────────────────────────────────

  // Contribution category IDs → cultural archive category IDs
  static const Map<String, String> _categoryMap = {
    'traditional_food': 'food',
    'handicraft': 'craft',
    'dance': 'dance',
    'architecture': 'architecture',
    'music': 'music',
    'traditional_clothing': 'clothing',
  };

  Future<void> addCulturalItem(Map<String, dynamic> data) async {
    await _culturalItems.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'Admin',
    });
  }

  Future<void> updateCulturalItem(
      String itemId, Map<String, dynamic> data) async {
    await _culturalItems.doc(itemId).update(data);
  }

  Future<void> deleteCulturalItem(String itemId, String imageUrl) async {
    await _culturalItems.doc(itemId).delete();
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    } catch (_) {
      // Image may already be gone or was a contribution URL — ignore
    }
  }

  Stream<List<Map<String, dynamic>>> getAllCulturalItems() {
    return _culturalItems
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }

  // ── Attractions ──────────────────────────────────────────────────────────────

  CollectionReference get _attractions => _firestore.collection('attractions');

  Future<void> addAttraction(Map<String, dynamic> data) async {
    await _attractions.add({
      ...data,
      'tags': [],
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'Admin',
    });
  }

  Future<void> updateAttraction(
      String attractionId, Map<String, dynamic> data) async {
    await _attractions.doc(attractionId).update(data);
  }

  Future<void> deleteAttraction(String attractionId) async {
    await _attractions.doc(attractionId).delete();
  }

  Future<Map<String, int>> migrateAllContent({String collection = 'all'}) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'migrateAllContent',
      options: HttpsCallableOptions(timeout: const Duration(minutes: 9)),
    );
    final result = await callable.call<Map<String, dynamic>>({
      'collection': collection,
    });

    // Convert dynamic counts to int
    final raw = result.data;
    return raw.map((key, value) => MapEntry(key, (value as num).toInt()));
  }

  // ── Events ───────────────────────────────────────────────────────────────────

  CollectionReference get _events => _firestore.collection('events');

  Future<void> addEvent(Map<String, dynamic> data) async {
    await _events.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'Admin',
    });
  }

  // ── Contributions Review ─────────────────────────────────────────────────────

  CollectionReference get _contributions =>
      _firestore.collection('contributions');

  Stream<List<ContributionModel>> getContributions() {
    return _contributions
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ContributionModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> approveContribution(
    String contributionId, {
    required String touristId,
    required String touristName,
    required int points,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String mediaUrl,
    required String category,
    required String regionId,
    required String adminId,
    required String adminName,
  }) async {
    final batch = _firestore.batch();

    final archiveRef = _culturalItems.doc();

    final regionEn = regionLabel(regionId, isArabic: false);
    final regionAr = regionLabel(regionId, isArabic: true);
    final categoryId = _categoryMap[category] ?? category;

    batch.set(archiveRef, {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': mediaUrl,
      'categoryId': categoryId,
      'regionId': regionId,
      'regionEn': regionEn,
      'regionAr': regionAr,
      'isContribution': true,
      'contributorId': touristId,
      'contributorName': touristName,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': adminId,
    });

    batch.update(_contributions.doc(contributionId), {
      'status': ContributionStatus.approved.name,
      'points': points,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'adminId': adminId,
      'adminName': adminName,
      'reviewedAt': Timestamp.now(),
      'archiveItemId': archiveRef.id,
    });

    batch.update(_users.doc(touristId), {
      'points': FieldValue.increment(points),
      'contributionsCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> rejectContribution(
    String contributionId, {
    required String touristId,
    required String adminId,
    required String adminName,
    required String reason,
  }) async {
    await _contributions.doc(contributionId).update({
      'status': ContributionStatus.rejected.name,
      'rejectionReason': reason,
      'adminId': adminId,
      'adminName': adminName,
      'reviewedAt': Timestamp.now(),
    });
  }
}
