import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:athar_app/features/contributions/logic/contribution_repository.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';

// Mocks — passed to the constructor so FirebaseFirestore.instance is never called.
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

// Helper to build a minimal ContributionModel for pure-logic tests.
ContributionModel makeContribution({
  String id = 'c1',
  ContributionStatus status = ContributionStatus.approved,
  int points = 40,
  int likes = 0,
  int shares = 0,
  String regionId = 'central',
}) {
  return ContributionModel(
    id: id,
    touristId: 'u1',
    touristName: 'Test User',
    touristEmail: 'test@example.com',
    category: 'traditional_food',
    submissionLanguage: 'ar',
    titleAr: 'عنوان',
    titleEn: 'Title',
    descriptionAr: 'وصف',
    descriptionEn: 'Description',
    regionId: regionId,
    cityId: 'riyadh',
    mediaUrl: 'https://example.com/media.jpg',
    mediaType: 'image',
    status: status,
    points: points,
    likes: likes,
    shares: shares,
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {
  late ContributionRepository repo;

  setUp(() {
    // Inject mocks so the constructor never touches FirebaseFirestore.instance.
    repo = ContributionRepository(
      firestore: MockFirebaseFirestore(),
      storage: MockFirebaseStorage(),
    );
  });

  // ─── getPoints ────────────────────────────────────────────────────────────

  group('ContributionRepository.getPoints', () {
    test(
        'UT-15: getPoints: known category "traditional_food" + mediaType "image" → 40',
        () {
      // Arrange
      const category = 'traditional_food';
      const mediaType = 'image';

      // Act
      final points = ContributionRepository.getPoints(category, mediaType);

      // Assert — value from _pointsMap in source
      expect(points, 40);
    });

    test(
        'UT-16: getPoints: known category "traditional_food" + mediaType "video" → higher than image',
        () {
      // Arrange
      const category = 'traditional_food';

      // Act
      final imagePoints = ContributionRepository.getPoints(category, 'image');
      final videoPoints = ContributionRepository.getPoints(category, 'video');

      // Assert — video (60) must exceed image (40)
      expect(videoPoints, greaterThan(imagePoints));
      expect(videoPoints, 60);
    });

    test(
        'UT-17: getPoints: unknown category "nonexistent" + mediaType "image" → fallback 40',
        () {
      // Arrange
      const category = 'nonexistent';
      const mediaType = 'image';

      // Act
      final points = ContributionRepository.getPoints(category, mediaType);

      // Assert — source: _pointsMap[categoryId]?[mediaType] ?? 40
      expect(points, 40);
    });

    test(
        'UT-18: getPoints: known category + unknown mediaType "gif" → fallback 40',
        () {
      // Arrange
      const category = 'traditional_food';
      const mediaType = 'gif';

      // Act
      final points = ContributionRepository.getPoints(category, mediaType);

      // Assert — mediaType not in inner map, falls back to 40
      expect(points, 40);
    });
  });

  // ─── computeStats ─────────────────────────────────────────────────────────

  group('ContributionRepository.computeStats', () {
    test('UT-19: computeStats: empty list → all aggregates are zero', () {
      // Arrange
      const contributions = <ContributionModel>[];

      // Act
      final stats = repo.computeStats(contributions);

      // Assert
      expect(stats.totalPoints, 0);
      expect(stats.totalLikes, 0);
      expect(stats.totalShares, 0);
      expect(stats.uniqueRegionCount, 0);
    });

    test(
        'UT-20: computeStats: single approved contribution → stats match exactly',
        () {
      // Arrange
      final contributions = [
        makeContribution(points: 50, likes: 10, shares: 3, regionId: 'western'),
      ];

      // Act
      final stats = repo.computeStats(contributions);

      // Assert
      expect(stats.totalPoints, 50);
      expect(stats.totalLikes, 10);
      expect(stats.totalShares, 3);
      expect(stats.uniqueRegionCount, 1);
    });

    test(
        'UT-21: computeStats: only pending/rejected contributions → totalPoints is 0',
        () {
      // Arrange
      final contributions = [
        makeContribution(status: ContributionStatus.pending, points: 40),
        makeContribution(status: ContributionStatus.rejected, points: 50),
      ];

      // Act
      final stats = repo.computeStats(contributions);

      // Assert — non-approved contributions are excluded
      expect(stats.totalPoints, 0);
      expect(stats.totalLikes, 0);
      expect(stats.uniqueRegionCount, 0);
    });

    test(
        'UT-22: computeStats: approved contributions with duplicate regions → uniqueRegionCount=2',
        () {
      // Arrange — central appears twice, western once
      final contributions = [
        makeContribution(id: 'c1', regionId: 'central'),
        makeContribution(id: 'c2', regionId: 'central'),
        makeContribution(id: 'c3', regionId: 'western'),
      ];

      // Act
      final stats = repo.computeStats(contributions);

      // Assert
      expect(stats.uniqueRegionCount, 2);
    });
  });

  // ─── computeAchievements ──────────────────────────────────────────────────

  group('ContributionRepository.computeAchievements', () {
    AchievementData find(List<AchievementData> list, String id) =>
        list.firstWhere((a) => a.id == id);

    test('UT-23: computeAchievements: empty list → all achievements locked',
        () {
      // Arrange
      const contributions = <ContributionModel>[];

      // Act
      final achievements = repo.computeAchievements(contributions);

      // Assert
      for (final a in achievements) {
        expect(a.isEarned, isFalse,
            reason: 'Expected ${a.id} to be locked with empty contributions');
      }
    });

    test(
        'UT-24: computeAchievements: exactly 1 approved contribution → first_contribution unlocked',
        () {
      // Arrange
      final contributions = [makeContribution()];

      // Act
      final achievements = repo.computeAchievements(contributions);

      // Assert
      expect(find(achievements, 'first_contribution').isEarned, isTrue);
    });

    test(
        'UT-25: computeAchievements: 10 approved → narrator unlocked; 9 leaves it locked',
        () {
      // Arrange — 10 approved
      final ten = List.generate(10, (i) => makeContribution(id: 'c$i'));

      // Act + Assert — 10 unlocks narrator
      final achievementsTen = repo.computeAchievements(ten);
      expect(find(achievementsTen, 'narrator').isEarned, isTrue);

      // Arrange — 9 approved
      final nine = List.generate(9, (i) => makeContribution(id: 'c$i'));

      // Act + Assert — 9 keeps narrator locked
      final achievementsNine = repo.computeAchievements(nine);
      expect(find(achievementsNine, 'narrator').isEarned, isFalse);
    });

    test(
        'UT-26: computeAchievements: 3 unique regions → explorer unlocked; 2 regions leaves it locked',
        () {
      // Arrange — 3 unique regions
      final threeRegions = [
        makeContribution(id: 'c1', regionId: 'central'),
        makeContribution(id: 'c2', regionId: 'western'),
        makeContribution(id: 'c3', regionId: 'eastern'),
      ];

      // Act + Assert — 3 regions unlocks explorer
      final achievementsThree = repo.computeAchievements(threeRegions);
      expect(find(achievementsThree, 'explorer').isEarned, isTrue);

      // Arrange — 2 unique regions
      final twoRegions = [
        makeContribution(id: 'c1', regionId: 'central'),
        makeContribution(id: 'c2', regionId: 'western'),
      ];

      // Act + Assert — 2 regions keeps explorer locked
      final achievementsTwo = repo.computeAchievements(twoRegions);
      expect(find(achievementsTwo, 'explorer').isEarned, isFalse);
    });

    test(
        'UT-27: computeAchievements: 50 total likes → loved unlocked; 49 leaves it locked',
        () {
      // Arrange — 50 likes total
      final fiftyLikes = [
        makeContribution(id: 'c1', likes: 30),
        makeContribution(id: 'c2', likes: 20),
      ];

      // Act + Assert — 50 unlocks loved
      final achievementsFifty = repo.computeAchievements(fiftyLikes);
      expect(find(achievementsFifty, 'loved').isEarned, isTrue);

      // Arrange — 49 likes total
      final fortyNineLikes = [
        makeContribution(id: 'c1', likes: 30),
        makeContribution(id: 'c2', likes: 19),
      ];

      // Act + Assert — 49 keeps loved locked
      final achievementsFortyNine = repo.computeAchievements(fortyNineLikes);
      expect(find(achievementsFortyNine, 'loved').isEarned, isFalse);
    });

    test(
        'UT-28: computeAchievements: 1000 total points → heritage_ambassador unlocked; 999 leaves it locked',
        () {
      // Arrange — 1000 points total
      final thousandPoints = [
        makeContribution(id: 'c1', points: 600),
        makeContribution(id: 'c2', points: 400),
      ];

      // Act + Assert — 1000 unlocks heritage_ambassador
      final achievementsThousand = repo.computeAchievements(thousandPoints);
      expect(find(achievementsThousand, 'heritage_ambassador').isEarned, isTrue);

      // Arrange — 999 points total
      final nineNineNine = [
        makeContribution(id: 'c1', points: 600),
        makeContribution(id: 'c2', points: 399),
      ];

      // Act + Assert — 999 keeps heritage_ambassador locked
      final achievementsNine = repo.computeAchievements(nineNineNine);
      expect(find(achievementsNine, 'heritage_ambassador').isEarned, isFalse);
    });
  });
}
