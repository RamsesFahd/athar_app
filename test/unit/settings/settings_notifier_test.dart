import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

void main() {
  group('SettingsNotifier - Locale and Toggles', () {

    late SettingsNotifier notifier;

    setUp(() {
      notifier = SettingsNotifier();
    });

    test('UT-38: setLocale switches state to Arabic', () {
      // Act
      notifier.setLocale(const Locale('ar'));

      // Assert
      expect(notifier.state.locale, equals(const Locale('ar')));
    });

    test('UT-39: setLocale switches state to English', () {
      // Act
      notifier.setLocale(const Locale('en'));

      // Assert
      expect(notifier.state.locale, equals(const Locale('en')));
    });

    test('UT-40: toggleContrast flips false to true', () {

      // Arrange
      expect(notifier.state.highContrast, isFalse);

      // Act
      notifier.toggleContrast();

      // Assert
      expect(notifier.state.highContrast, isTrue);
    });

    test('UT-41: toggleContrast twice returns to original state', () {

      // Arrange
      final initial = notifier.state.highContrast;

      // Act
      notifier.toggleContrast();
      notifier.toggleContrast();

      // Assert
      expect(notifier.state.highContrast, equals(initial));
    });

    test('UT-42: toggleTts flips state', () {

      // Arrange
      final initial = notifier.state.isTtsEnabled;

      // Act
      notifier.toggleTts();

      // Assert
      expect(notifier.state.isTtsEnabled, equals(!initial));
    });
  });
}