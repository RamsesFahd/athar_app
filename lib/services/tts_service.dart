import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
// استيراد المزود الخاص بك لمعرفة اللغة وحالة التفعيل
import 'package:athar_app/core/providers/settings_provider.dart';

class TtsService {
  final FlutterTts _flutterTts;
  final Ref ref;

  // [test injection] The optional `tts` parameter allows unit tests to inject a
  // mock FlutterTts without hitting the platform plugin.
  TtsService(this.ref, {FlutterTts? tts}) : _flutterTts = tts ?? FlutterTts() {
    _initTts();
  }

  // تهيئة إعدادات الصوت الأساسية
  void _initTts() async {
    await _flutterTts.setVolume(1.0);
    // تقليل السرعة قليلاً لتكون مريحة لكبار السن وذوي الاحتياجات
    await _flutterTts.setSpeechRate(0.45); 
    await _flutterTts.setPitch(1.0);
  }

  // الدالة الرئيسية لنطق النصوص
  Future<void> speak(String text) async {
    final settings = ref.read(settingsProvider);

    // 1. إذا كان القارئ معطلاً من الإعدادات، لا تفعل شيئاً
    if (!settings.isTtsEnabled) return;

    // 2. تحديد لغة النطق بأمان
    if (settings.locale.languageCode == 'ar') {
      // نفحص أولاً إذا كانت "ar-SA" مدعومة
      var isSaAvailable = await _flutterTts.isLanguageAvailable("ar-SA");
      if (isSaAvailable) {
        await _flutterTts.setLanguage("ar-SA");
      } else {
        // إذا لم تكن مدعومة، نستخدم الكود العام "ar"
        await _flutterTts.setLanguage("ar");
      }
    } else {
      await _flutterTts.setLanguage("en-US");
    }

    // 3. نطق النص
    await _flutterTts.speak(text);
  }

  // إيقاف النطق
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

// توفير الخدمة عبر Riverpod لتكون متاحة في كل التطبيق
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService(ref);
});