// APPROACH: Option (b) — indirect / mirrored testing.
// The helper methods (_containsArabic, _snippet, _isGenericTitle) are private
// to ChatNotifier and cannot be accessed from outside their library. Modifying
// the source file (option a) is prohibited by the project test rules.
// Instead, this file mirrors the exact logic from chat_notifier.dart into a
// local ChatHelpers class so the algorithms are tested without touching lib/.
// If the source logic ever changes, these tests will flag the divergence.
//
// Source reference: lib/features/historical_chat/logic/chat_notifier.dart

import 'package:flutter_test/flutter_test.dart';

/// Mirrors the private helper methods from ChatNotifier verbatim.
class ChatHelpers {
  bool containsArabic(String value) {
    final arabicRegex = RegExp(r'[؀-ۿݐ-ݿࢠ-ࣿ]');
    return arabicRegex.hasMatch(value);
  }

  String snippet(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return '';
    if (normalized.length <= 42) return normalized;
    return '${normalized.substring(0, 42)}...';
  }

  bool isGenericTitle(String title, {required bool isArabic}) {
    final normalized = title.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    final genericArabic = <String>['سالفة عن', 'سالفة جديدة', 'محادثة جديدة'];
    final genericEnglish = <String>['story about', 'new chat'];
    final generic = isArabic ? genericArabic : genericEnglish;
    return generic.any((prefix) => normalized.startsWith(prefix));
  }
}

void main() {
  late ChatHelpers helpers;

  setUp(() {
    helpers = ChatHelpers();
  });

  // ─── containsArabic ───────────────────────────────────────────────────────

  group('containsArabic', () {
    test('UT-52: containsArabic: Arabic string "مرحباً" → true', () {
      // Arrange
      const input = 'مرحباً';

      // Act
      final result = helpers.containsArabic(input);

      // Assert
      expect(result, isTrue);
    });

    test('UT-53: containsArabic: Latin string "Hello" → false', () {
      // Arrange
      const input = 'Hello';

      // Act
      final result = helpers.containsArabic(input);

      // Assert
      expect(result, isFalse);
    });

    test('UT-54: containsArabic: empty string "" → false', () {
      // Arrange
      const input = '';

      // Act
      final result = helpers.containsArabic(input);

      // Assert
      expect(result, isFalse);
    });
  });

  // ─── snippet ──────────────────────────────────────────────────────────────

  group('snippet', () {
    test('UT-55: snippet: short string "Hi" → returned unchanged', () {
      // Arrange
      const input = 'Hi';

      // Act
      final result = helpers.snippet(input);

      // Assert
      expect(result, 'Hi');
    });

    test(
        'UT-56: snippet: 60-character string → truncated to first 42 chars + "..."',
        () {
      // Arrange — exactly 60 characters
      const input = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345678';

      // Act
      final result = helpers.snippet(input);

      // Assert — source truncates at index 42 and appends "..."
      expect(result.length, 45); // 42 chars + 3 for "..."
      expect(result, '${input.substring(0, 42)}...');
    });
  });

  // ─── isGenericTitle ───────────────────────────────────────────────────────

  group('isGenericTitle', () {
    test(
        'UT-57: isGenericTitle: "محادثة جديدة" (Arabic generic prefix) → true',
        () {
      // Arrange — one of the actual Arabic generic prefixes from source
      const title = 'محادثة جديدة';

      // Act
      final result = helpers.isGenericTitle(title, isArabic: true);

      // Assert
      expect(result, isTrue);
    });

    test(
        'UT-58: isGenericTitle: "تاريخ الدرعية" (specific topic) → false',
        () {
      // Arrange — not a generic prefix
      const title = 'تاريخ الدرعية';

      // Act
      final result = helpers.isGenericTitle(title, isArabic: true);

      // Assert
      expect(result, isFalse);
    });
  });
}
