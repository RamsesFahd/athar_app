import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/models/user/user_model.dart';

void main() {
  group('AccessibilitySettings', () {
    test('UT-66: fromMap(null) returns default accessibility settings', () {
      final settings = AccessibilitySettings.fromMap(null);

      expect(settings.fontSize, 'medium');
      expect(settings.highContrast, isFalse);
      expect(settings.languagePreference, 'ar');
      expect(settings.textReaderEnabled, isFalse);
    });
  });

  group('UserModel.fromMap', () {
    test('UT-67: role "admin" creates AdminModel', () {
      final user = UserModel.fromMap({
        'uId': 'admin-1',
        'fullName': 'Admin User',
        'email': 'admin@example.com',
        'role': 'admin',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      expect(user, isA<AdminModel>());
      expect(user.role, UserRole.admin);
      expect(user.fullName, 'Admin User');
    });

    test('UT-68: unknown role falls back to TouristModel', () {
      final user = UserModel.fromMap({
        'uId': 'u1',
        'fullName': 'Tourist User',
        'email': 'tourist@example.com',
        'role': 'unknown',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      expect(user, isA<TouristModel>());
      expect(user.role, UserRole.tourist);
    });
  });

  group('TutorModel - Credential Helpers', () {
    TutorModel makeTutor({
      TutorType tutorType = TutorType.individual,
      VerificationStatus verificationStatus = VerificationStatus.verified,
      bool phoneVerified = true,
      String? bio = 'Experienced guide',
      List<String>? languages = const ['ar', 'en'],
      DateTime? licenceExpiryDate,
      DateTime? commercialRegExpiryDate,
      DateTime? tourismLicenceExpiryDate,
    }) {
      return TutorModel(
        uId: 'tutor-1',
        fullName: 'Guide Name',
        email: 'guide@example.com',
        phoneVerified: phoneVerified,
        createdAt: DateTime(2024, 1, 1),
        accessibilitySettings: AccessibilitySettings(),
        tutorType: tutorType,
        verificationStatus: verificationStatus,
        bio: bio,
        languages: languages,
        licenceNumber: 'LIC-1',
        licenceExpiryDate:
            licenceExpiryDate ?? DateTime.now().add(const Duration(days: 90)),
        companyName: tutorType == TutorType.company ? 'Company' : null,
        commercialRegistration: tutorType == TutorType.company ? 'CR-1' : null,
        commercialRegExpiryDate: commercialRegExpiryDate,
        tourismLicenceNumber: tutorType == TutorType.company ? 'TL-1' : null,
        tourismLicenceExpiryDate: tourismLicenceExpiryDate,
      );
    }

    test('UT-69: verified tutor with valid profile can publish trips', () {
      final tutor = makeTutor();

      expect(tutor.isCredentialValid, isTrue);
      expect(tutor.canPublishTrips, isTrue);
      expect(tutor.missingTripRequirements, isEmpty);
    });

    test('UT-70: missing phone, bio, languages, and verification are reported',
        () {
      final tutor = makeTutor(
        verificationStatus: VerificationStatus.pending,
        phoneVerified: false,
        bio: '',
        languages: const [],
      );

      expect(tutor.canPublishTrips, isFalse);
      expect(tutor.missingTripRequirements, [
        'phone_verification',
        'guide_verification',
        'bio',
        'languages',
      ]);
    });

    test('UT-71: expired individual credential is invalid', () {
      final tutor = makeTutor(
        licenceExpiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(tutor.isCredentialExpired, isTrue);
      expect(tutor.isCredentialValid, isFalse);
    });

  });
}
