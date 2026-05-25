import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

class TtsService {
  final FlutterTts _flutterTts;
  final Ref ref;
   bool _isSpeaking = false;

  // [test injection] The optional `tts` parameter allows unit tests to inject a
  // mock FlutterTts without hitting the platform plugin.
  TtsService(this.ref, {FlutterTts? tts}) : _flutterTts = tts ?? FlutterTts() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTts());
  }

  // تهيئة إعدادات الصوت الأساسية
  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    // تقليل السرعة قليلاً لتكون مريحة لكبار السن وذوي الاحتياجات
    await _flutterTts.setSpeechRate(0.52);
  await _flutterTts.setPitch(1.15);

  _flutterTts.setCompletionHandler(() {
    _isSpeaking = false;
  });

  _flutterTts.setCancelHandler(() {
    _isSpeaking = false;
  });

     await _flutterTts.setVoice({
    "name": "ar-xa-x-arm-network",
    "locale": "ar-SA",
  });
  }

  // Main function for reading text aloud
Future<void> speak(String text) async {
  final settings = ref.read(settingsProvider);

  // If Text-to-Speech is disabled from accessibility settings, do nothing
  if (!settings.isTtsEnabled) return;

  // If audio is already playing, stop it instead of replaying
  if (_isSpeaking) {
    await stop();
    return;
  }

  // Mark TTS as currently speaking
  _isSpeaking = true;

  // Configure language safely based on selected app locale
  if (settings.locale.languageCode == 'ar') {

    // Check if Saudi Arabic voice is available
    final isSaAvailable =
        await _flutterTts.isLanguageAvailable("ar-SA");

    if (isSaAvailable) {

      // Use Saudi Arabic voice if supported
      await _flutterTts.setLanguage("ar-SA");

    } else {

      // Fallback to generic Arabic voice
      await _flutterTts.setLanguage("ar");
    }

  } else {

    // Use English (US) voice
    await _flutterTts.setLanguage("en-US");
  }

  // Start speaking the provided text
  await _flutterTts.speak(text);
}

// Stop current speech playback
Future<void> stop() async {

  // Reset speaking state
  _isSpeaking = false;

  // Stop Text-to-Speech immediately
  await _flutterTts.stop();
}
}

// توفير الخدمة عبر Riverpod لتكون متاحة في كل التطبيق
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService(ref);
});