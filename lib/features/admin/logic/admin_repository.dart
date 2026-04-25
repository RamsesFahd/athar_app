import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';

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

  Future<void> approveTrip(String tripId) async {
    await _trips.doc(tripId).update({'status': 'approved'});
  }

  Future<void> rejectTrip(String tripId) async {
    await _trips.doc(tripId).update({'status': 'rejected'});
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

  Future<void> addCulturalItem(Map<String, dynamic> data) async {
    await _culturalItems.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'Admin',
    });
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
}
