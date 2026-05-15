// Tests for TtsService language selection and stop behaviour.
// UT-43 through UT-46.
//
// SOURCE MODIFICATION NOTE:
//   lib/services/tts_service.dart constructor was updated to accept an optional
//   `FlutterTts? tts` parameter so tests can inject a mock without hitting the
//   platform plugin:
//     TtsService(this.ref, {FlutterTts? tts}) : _flutterTts = tts ?? FlutterTts()
//
// LANGUAGE DETECTION NOTE:
//   TtsService determines the TTS language from the app settings locale
//   (ref.read(settingsProvider).locale.languageCode), NOT from text-character
//   analysis. Tests therefore control language selection by supplying the
//   appropriate locale via a mocked Ref.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:athar_app/services/tts_service.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockFlutterTts extends Mock implements FlutterTts {}

class MockRef extends Mock implements Ref {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
AppSettings _settings({required String languageCode, bool ttsEnabled = true}) {
  return AppSettings(
    fontSize: AppFontSize.medium,
    locale: Locale(languageCode),
    isTtsEnabled: ttsEnabled,
  );
}

/// Stubs the boilerplate FlutterTts calls that happen in _initTts and speak.
void _stubTts(MockFlutterTts tts, {bool arSaAvailable = true}) {
  when(() => tts.setVolume(any())).thenAnswer((_) async => null);
  when(() => tts.setSpeechRate(any())).thenAnswer((_) async => null);
  when(() => tts.setPitch(any())).thenAnswer((_) async => null);
  when(() => tts.isLanguageAvailable(any())).thenAnswer((_) async => arSaAvailable);
  when(() => tts.setLanguage(any())).thenAnswer((_) async => null);
  when(() => tts.speak(any())).thenAnswer((_) async => null);
  when(() => tts.stop()).thenAnswer((_) async => null);
}

void main() {
  late MockFlutterTts mockTts;
  late MockRef mockRef;

  setUp(() {
    mockTts = MockFlutterTts();
    mockRef = MockRef();
    _stubTts(mockTts);
  });

  group('TtsService', () {
    // UT-43 ----------------------------------------------------------------
    test('UT-43: speak() with Arabic locale calls setLanguage("ar-SA") before speak', () async {
      when(() => mockRef.read(settingsProvider))
          .thenReturn(_settings(languageCode: 'ar'));

      final service = TtsService(mockRef, tts: mockTts);
      await service.speak('مرحباً بكم في الأثر');

      verifyInOrder([
        () => mockTts.setLanguage('ar-SA'),
        () => mockTts.speak('مرحباً بكم في الأثر'),
      ]);
    });

    // UT-44 ----------------------------------------------------------------
    test('UT-44: speak() with English locale calls setLanguage("en-US") before speak', () async {
      when(() => mockRef.read(settingsProvider))
          .thenReturn(_settings(languageCode: 'en'));

      final service = TtsService(mockRef, tts: mockTts);
      await service.speak('Welcome to Athar');

      verifyInOrder([
        () => mockTts.setLanguage('en-US'),
        () => mockTts.speak('Welcome to Athar'),
      ]);
    });

    // UT-45 ----------------------------------------------------------------
    // Language is controlled by the app locale, not text content.
    // With Arabic locale active, even mixed-script text triggers "ar-SA".
    test('UT-45: speak() with Arabic locale and mixed-script text still sets "ar-SA"', () async {
      when(() => mockRef.read(settingsProvider))
          .thenReturn(_settings(languageCode: 'ar'));

      final service = TtsService(mockRef, tts: mockTts);
      await service.speak('Hello مرحباً');

      verify(() => mockTts.setLanguage('ar-SA')).called(1);
      verify(() => mockTts.speak('Hello مرحباً')).called(1);
    });

    // UT-46 ----------------------------------------------------------------
    test('UT-46: stop() calls FlutterTts.stop() and does not throw', () async {
      when(() => mockRef.read(settingsProvider))
          .thenReturn(_settings(languageCode: 'ar'));

      final service = TtsService(mockRef, tts: mockTts);
      // Simulate an in-progress speak, then stop.
      service.speak('...'); // fire-and-forget
      await expectLater(service.stop(), completes);

      verify(() => mockTts.stop()).called(1);
    });
  });
}
