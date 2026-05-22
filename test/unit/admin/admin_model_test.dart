import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/models/user/user_model.dart';

void main() {
  group('AdminModel', () {
    test('UT-73: toMap/fromMap round-trip preserves admin fields', () {
      final createdAt = DateTime(2024, 1, 1);
      final original = AdminModel(
        uId: 'admin-1',
        fullName: 'Admin User',
        email: 'admin@example.com',
        createdAt: createdAt,
        profileImage: 'admin.png',
        accessibilitySettings: AccessibilitySettings(
          fontSize: 'large',
          highContrast: true,
          languagePreference: 'en',
          textReaderEnabled: true,
        ),
      );

      final restored = AdminModel.fromMap(original.toMap());

      expect(restored.uId, original.uId);
      expect(restored.fullName, original.fullName);
      expect(restored.email, original.email);
      expect(restored.role, UserRole.admin);
      expect(restored.createdAt, original.createdAt);
      expect(restored.profileImage, original.profileImage);
      expect(restored.accessibilitySettings.fontSize, 'large');
      expect(restored.accessibilitySettings.highContrast, isTrue);
    });

    test('UT-74: fromMap supplies admin defaults for missing optional fields',
        () {
      final admin = AdminModel.fromMap({
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      expect(admin.uId, '');
      expect(admin.fullName, 'Admin');
      expect(admin.email, '');
      expect(admin.role, UserRole.admin);
      expect(admin.accessibilitySettings.fontSize, 'medium');
    });
  });
}
