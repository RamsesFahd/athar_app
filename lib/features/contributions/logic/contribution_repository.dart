import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/notifications/logic/notifications_repository.dart';

part 'contribution_repository.g.dart';

@riverpod
ContributionRepository contributionRepository(Ref ref) {
  return ContributionRepository();
}

/// Streams the sum of likes across all approved contributions for a tourist.
/// Used in the tourist profile header to show a live heart count.
final touristTotalLikesProvider =
    StreamProvider.autoDispose.family<int, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('contributions')
      .where('touristId', isEqualTo: uid)
      .where('status', isEqualTo: ContributionStatus.approved.name)
      .snapshots()
      .map((snap) => snap.docs.fold<int>(
            0,
            (acc, doc) =>
                acc + ((doc.data()['likes'] as num?)?.toInt() ?? 0),
          ));
});

/// Streams the tourist's Firestore document so points/count stay live
/// even after an admin approves a contribution in the background.
@riverpod
Stream<TouristModel?> touristStream(Ref ref, String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final model = UserModel.fromMap(doc.data()!);
    return model is TouristModel ? model : null;
  });
}

class ContributionStats {
  final int totalPoints;
  final int contributionsCount;
  final int totalLikes;
  final int totalShares;
  final int uniqueRegionCount;
  final int qualityBonusCount;

  const ContributionStats({
    required this.totalPoints,
    required this.contributionsCount,
    required this.totalLikes,
    required this.totalShares,
    required this.uniqueRegionCount,
    required this.qualityBonusCount,
  });
}

class AchievementData {
  final String id;
  final bool isEarned;
  final int current;
  final int target;

  const AchievementData({
    required this.id,
    required this.isEarned,
    required this.current,
    required this.target,
  });
}

class ContributionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ContributionRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference get _contributions =>
      _firestore.collection('contributions');

  // Points map: category → mediaType → points
  static const Map<String, Map<String, int>> _pointsMap = {
    'traditional_food': {'image': 40, 'video': 60},
    'handicraft': {'image': 50, 'video': 70},
    'dance': {'image': 50, 'video': 80},
    'architecture': {'image': 30, 'video': 50},
    'music': {'image': 50, 'video': 70},
    'traditional_clothing': {'image': 40, 'video': 60},
  };

  static int getPoints(String categoryId, String mediaType) =>
      _pointsMap[categoryId]?[mediaType] ?? 40;

  Future<void> submitContribution({
    required TouristModel tourist,
    required String categoryId,
    required String titleContent,
    required String descriptionContent,
    required String submissionLanguage,
    required String regionId,
    required String cityId,
    required File mediaFile,
    required String mediaType,
  }) async {
    final docRef = _contributions.doc();
    final id = docRef.id;

    final ext = mediaFile.path.split('.').last;
    final storageRef = _storage.ref('contributions/${tourist.uId}/$id.$ext');
    final uploadTask = await storageRef.putFile(mediaFile);
    final mediaUrl = await uploadTask.ref.getDownloadURL();

    await docRef.set({
      'id': id,
      'touristId': tourist.uId,
      'touristName': tourist.fullName,
      'touristEmail': tourist.email,
      'category': categoryId,
      'submissionLanguage': submissionLanguage,
      'titleAr': submissionLanguage == 'ar' ? titleContent : '',
      'titleEn': submissionLanguage == 'en' ? titleContent : '',
      'descriptionAr': submissionLanguage == 'ar' ? descriptionContent : '',
      'descriptionEn': submissionLanguage == 'en' ? descriptionContent : '',
      'regionId': regionId,
      'cityId': cityId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'status': ContributionStatus.pending.name,
      'points': 0,
      'likes': 0,
      'shares': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'rejectionReason': null,
      'adminId': null,
      'adminName': null,
      'reviewedAt': null,
    });

    // Notify all admins that a new contribution needs review.
    final adminSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.admin.name)
        .get();
    final notifRepo = NotificationsRepository();
    for (final doc in adminSnap.docs) {
      await notifRepo.addNotification(
        userId: doc.id,
        type: 'contribution_submitted',
      );
    }
  }

  Stream<List<ContributionModel>> getTouristContributions(String touristId) {
    return _contributions
        .where('touristId', isEqualTo: touristId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ContributionModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  ContributionStats computeStats(List<ContributionModel> all) {
    final approved =
        all.where((c) => c.status == ContributionStatus.approved).toList();
    return ContributionStats(
      // Derived from the live contributions stream — stays in sync when admin approves
      totalPoints: approved.fold(0, (acc, c) => acc + c.points),
      contributionsCount: approved.length,
      totalLikes: approved.fold(0, (acc, c) => acc + c.likes),
      totalShares: approved.fold(0, (acc, c) => acc + c.shares),
      uniqueRegionCount: approved.map((c) => c.regionId).toSet().length,
      qualityBonusCount: approved.where((c) => c.points >= 60).length,
    );
  }

  List<AchievementData> computeAchievements(List<ContributionModel> all) {
    final approved =
        all.where((c) => c.status == ContributionStatus.approved).toList();
    final totalLikes = approved.fold(0, (acc, c) => acc + c.likes);
    final totalPoints = approved.fold(0, (acc, c) => acc + c.points);
    final count = approved.length;
    final uniqueRegions = approved.map((c) => c.regionId).toSet().length;

    return [
      AchievementData(
        id: 'first_contribution',
        isEarned: count >= 1,
        current: count.clamp(0, 1),
        target: 1,
      ),
      AchievementData(
        id: 'narrator',
        isEarned: count >= 10,
        current: count.clamp(0, 10),
        target: 10,
      ),
      AchievementData(
        id: 'explorer',
        isEarned: uniqueRegions >= 3,
        current: uniqueRegions.clamp(0, 3),
        target: 3,
      ),
      AchievementData(
        id: 'loved',
        isEarned: totalLikes >= 50,
        current: totalLikes.clamp(0, 50),
        target: 50,
      ),
      AchievementData(
        id: 'heritage_ambassador',
        isEarned: totalPoints >= 1000,
        current: totalPoints.clamp(0, 1000),
        target: 1000,
      ),
    ];
  }
}
