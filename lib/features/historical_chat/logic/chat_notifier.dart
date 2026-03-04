import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../logic/chat_repository.dart';
import '../../../../services/gemini_service.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

part 'chat_notifier.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  bool build() => false;

  bool _containsArabic(String value) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(value);
  }

  Future<void> sendUserMessage({
    RegionModel? region,
    required String text,
  }) async {
    state = true; // بدء حالة التحميل (Loading)

    try {
      final cleanText = text.trim();

      // --- الخطوة 1: جلب البيانات الأساسية (داخل الـ try لضمان الأمان) ---
      final authRepo = ref.read(authRepositoryProvider);
      final userId = authRepo.currentUser?.uid ?? 'guest_user';
      final settings = ref.read(settingsProvider);
      final langCode = settings.locale.languageCode;
      final effectiveLangCode = _containsArabic(cleanText) ? 'ar' : langCode;
      final repository = ref.read(chatRepositoryProvider);
      final gemini = ref.read(geminiServiceProvider);

      final String currentChatId = region?.regionId ?? 'general';
      String systemInstruction = '';

      // --- الخطوة 2: بناء التعليمات البرمجية ---
      if (region != null) {
        final culturalRepo = ref.read(culturalRepositoryProvider);
        final allItems = await culturalRepo.fetchItems();

        final regionalItems = allItems
            .where((item) =>
                item.regionAr == region.nameAr ||
                item.regionEn == region.nameEn)
            .toList();

        final itemsTitles = regionalItems
            .map((e) => effectiveLangCode == 'ar' ? e.titleAr : e.titleEn)
            .join('، ');

        systemInstruction = '''
          You are the "Athar Cultural Assistant" for the ${region.nameEn}.
          Personality: Proud, hospitable, and knowledgeable.
          DYNAMIC CONTEXT: Items in archive for this region: [$itemsTitles].
          RULES:
          1. Language: YOU MUST RESPOND IN ${effectiveLangCode == 'ar' ? 'ARABIC' : 'ENGLISH'}.
          2. Cultural Greeting: ${region.systemPrompt}
          3. Smart Navigation: Use #tags# for archive items.
          4. Suggestions: End with 3 topics starting with *.
        ''';
      } else {
        systemInstruction = '''
          أنت "راوي"، المساعد الثقافي العام لتطبيق أثر.
          اللغة: يجب أن تتحدث بـ (${effectiveLangCode == 'ar' ? 'العربية' : 'الإنجليزية'}).
          مهمتك: الترحيب بالمستخدم ودعوته لاختيار منطقة معينة من القائمة بالأسفل.
        ''';
      }

      // --- الخطوة 3: حفظ رسالة المستخدم أولاً ---
      final userMessage = ChatMessageModel(
        text: cleanText,
        senderId: userId,
        isUser: true,
        timestamp: DateTime.now(),
      );
      await repository.saveMessage(userId, currentChatId, userMessage);

      // --- الخطوة 4: طلب الرد من Gemini ---
      final promptWithLanguageGuard = effectiveLangCode == 'ar'
          ? 'أجب باللغة العربية الفصحى فقط، ولا تستخدم الإنجليزية إلا إذا طُلب منك ذلك صراحةً.\n\n$cleanText'
          : 'Answer in English only unless the user explicitly asks for Arabic.\n\n$cleanText';

      final response = await gemini.getResponse(
        prompt: promptWithLanguageGuard,
        systemInstruction: systemInstruction,
      );

      final botMessage = ChatMessageModel(
        text: response,
        senderId: 'bot',
        isUser: false,
        timestamp: DateTime.now(),
      );

      // حفظ رد البوت
      await repository.saveMessage(userId, currentChatId, botMessage);
    } catch (e) {
      final authRepo = ref.read(authRepositoryProvider);
      final userId = authRepo.currentUser?.uid ?? 'guest_user';
      final repository = ref.read(chatRepositoryProvider);
      final currentChatId = region?.regionId ?? 'general';

      final errorMessage = ChatMessageModel(
        text:
            'تعذر الاتصال بخدمة Gemini حالياً. تأكد من مفتاح API والاتصال بالإنترنت ثم حاول مرة أخرى.',
        senderId: 'bot',
        isUser: false,
        timestamp: DateTime.now(),
      );

      await repository.saveMessage(userId, currentChatId, errorMessage);

      // طباعة الخطأ بوضوح في التيرمنال للتشخيص
      print("❌ Error in sendUserMessage: $e");
    } finally {
      state = false; // التأكد دائماً من إغلاق حالة التحميل
    }
  }
}
