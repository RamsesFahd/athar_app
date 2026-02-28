import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../logic/chat_repository.dart';
import '../../../../services/gemini_service.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
part 'chat_notifier.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  bool build() => false; // الحالة الابتدائية: لا يوجد تحميل

  Future<void> sendUserMessage({
    required String userId,
    required String regionId,
    required String text,
    required String systemPrompt,
  }) async {
    state = true;

    final userMessage = ChatMessageModel(
      text: text,
      senderId: userId,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // الوصول للبروفايدرز الآخرين يتم عبر ref
    final repository = ref.read(chatRepositoryProvider);
    final gemini = ref.read(geminiServiceProvider);

    await repository.saveMessage(userId, regionId, userMessage);

    try {
      final response = await gemini.getResponse(
        prompt: text,
        systemInstruction: systemPrompt,
      );

      final botMessage = ChatMessageModel(
        text: response,
        senderId: 'bot',
        isUser: false,
        timestamp: DateTime.now(),
      );

      await repository.saveMessage(userId, regionId, botMessage);
    } finally {
      state = false;
    }
  }
}
