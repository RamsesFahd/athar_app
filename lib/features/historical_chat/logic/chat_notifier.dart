import 'package:athar_app/core/models/chat/chat_session_model.dart';
import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../logic/chat_repository.dart';
import '../../../../services/gemini_service.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'dart:typed_data';
part 'chat_notifier.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  bool build() => false;

  bool _containsArabic(String value) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(value);
  }

  // Task 4: Greeting Logic
  Future<void> sendInitialGreeting({
    required RegionModel region,
    required String sessionId,
  }) async {
    state = true;
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userId = authRepo.currentUser?.uid ?? 'guest_user';
      final repository = ref.read(chatRepositoryProvider);
      final gemini = ref.read(geminiServiceProvider);

      // Save session metadata
      final newSession = ChatSessionModel(
        sessionId: sessionId,
        regionId: region.regionId,
        title: "سالفة عن ${region.nameAr}",
        lastMessageTime: DateTime.now(),
      );
      await repository.createSession(userId, newSession);

      // Initial prompt to Rawi
      final response = await gemini.getResponse(
        prompt: "ابدأ الترحيب بالمستخدم في منطقة ${region.nameAr} بأسلوبك كراوي قصص.",
        systemInstruction: region.systemPrompt,
      );

      final botMessage = ChatMessageModel(
        text: response,
        senderId: 'bot',
        isUser: false,
        timestamp: DateTime.now(),
      );
      await repository.saveMessage(userId, sessionId, botMessage);
    } catch (e) {
      print("❌ Error: $e");
    } finally {
      state = false;
    }
  }

  Future<void> sendUserMessage({
    RegionModel? region,
    required String text,
    required String sessionId,
    Uint8List? imageBytes,
  }) async {
    state = true;
    try {
      final cleanText = text.trim();
      final authRepo = ref.read(authRepositoryProvider);
      final userId = authRepo.currentUser?.uid ?? 'guest_user';
      final settings = ref.read(settingsProvider);
      final langCode = settings.locale.languageCode;
      final effectiveLangCode = _containsArabic(cleanText) ? 'ar' : langCode;
      final repository = ref.read(chatRepositoryProvider);
      final gemini = ref.read(geminiServiceProvider);

      String systemInstruction = '';
      if (region != null) {
        final culturalRepo = ref.read(culturalRepositoryProvider);
        final allItems = await culturalRepo.fetchItems();
        final regionalItems = allItems.where((item) =>
            item.regionAr == region.nameAr || item.regionEn == region.nameEn).toList();
        final itemsTitles = regionalItems.map((e) => 
            effectiveLangCode == 'ar' ? e.titleAr : e.titleEn).join('، ');

        systemInstruction = '''
          You are the "Athar Cultural Assistant" for the ${region.nameEn}.
          Personality: Proud, hospitable, and knowledgeable.
          DYNAMIC CONTEXT: Items in archive for this region: [$itemsTitles].
          RULES:
          1. Language: RESPOND IN ${effectiveLangCode == 'ar' ? 'ARABIC' : 'ENGLISH'}.
          2. Cultural Greeting: ${region.systemPrompt}
          3. Smart Navigation: Use #tags# for archive items.
          4. Suggestions: End with 3 topics starting with *.
        ''';
      }

      // Save user message
      await repository.saveMessage(userId, sessionId, 
          ChatMessageModel(text: cleanText, senderId: userId, isUser: true, timestamp: DateTime.now()));

      // Get Gemini response
      final response = await gemini.getResponse(
        prompt: cleanText,
        systemInstruction: systemInstruction,
        imageBytes: imageBytes,
      );

      // Save bot response
      await repository.saveMessage(userId, sessionId, 
          ChatMessageModel(text: response, senderId: 'bot', isUser: false, timestamp: DateTime.now()));
    } finally {
      state = false;
    }
  }
}