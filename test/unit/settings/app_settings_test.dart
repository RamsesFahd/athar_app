import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

void main() {

  group('AppSettings - copyWith Immutability', () {

    test('UT-36: copyWith modifies only specified field', () {

      // Arrange
      final original = AppSettings(
        fontSize: AppFontSize.medium,
        locale: const Locale('en'),
        highContrast: false,
        isTtsEnabled: false,
      );

      // Act
      final modified =
          original.copyWith(fontSize: AppFontSize.large);

      // Assert
      expect(modified.fontSize,
          equals(AppFontSize.large));

      expect(modified.locale,
          equals(original.locale));

      expect(modified.highContrast,
          equals(original.highContrast));

      expect(modified.isTtsEnabled,
          equals(original.isTtsEnabled));
    });

    test('UT-37: copyWith with no arguments returns equivalent object', () {

      // Arrange
      final original = AppSettings(
        fontSize: AppFontSize.medium,
        locale: const Locale('ar'),
        highContrast: true,
        isTtsEnabled: false,
      );

      // Act
      final copy = original.copyWith();

      // Assert
      expect(copy.fontSize,
          equals(original.fontSize));

      expect(copy.locale,
          equals(original.locale));

      expect(copy.highContrast,
          equals(original.highContrast));

      expect(copy.isTtsEnabled,
          equals(original.isTtsEnabled));
    });

    test('UT-43: copyWith modifies locale only', () {

      // Arrange
      final original = AppSettings(
        fontSize: AppFontSize.medium,
        locale: const Locale('en'),
        highContrast: false,
        isTtsEnabled: false,
      );

      // Act
      final modified =
          original.copyWith(
              locale: const Locale('ar'));

      // Assert
      expect(modified.locale,
          equals(const Locale('ar')));

      expect(modified.fontSize,
          equals(original.fontSize));

      expect(modified.highContrast,
          equals(original.highContrast));

      expect(modified.isTtsEnabled,
          equals(original.isTtsEnabled));
    });
  });
}