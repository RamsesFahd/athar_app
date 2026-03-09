import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/historical_chat/widgets/smart_text_content.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool showQuickReplies;
  final bool isAr;
  final ValueChanged<String> onTapQuickReply;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showQuickReplies,
    required this.isAr,
    required this.onTapQuickReply,
  });

  ({String mainText, List<String> quickReplies}) _splitMessageContent(
      String rawMessage) {
    final allLines = rawMessage.split('\n');
    final quickReplies = allLines
        .where((line) => line.trim().startsWith('*'))
        .map((line) => line.trim().substring(1).trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final mainText = allLines
        .where((line) => !line.trim().startsWith('*'))
        .join('\n')
        .trim();

    return (mainText: mainText, quickReplies: quickReplies);
  }

  bool _containsArabic(String value) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final parts = _splitMessageContent(message);
    final isArabic = _containsArabic(parts.mainText);
    final showBubble = isMe || parts.mainText.isNotEmpty;
    final visibleQuickReplies = showQuickReplies
        ? parts.quickReplies.take(3).toList()
        : const <String>[];

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showBubble)
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : const Color(0xFF2D3A2A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: SmartTextContent(
                  text: parts.mainText,
                  isMe: isMe,
                ),
              ),
            ),
          ),
        if (!isMe && visibleQuickReplies.isNotEmpty)
          Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 6, end: 6, bottom: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: visibleQuickReplies.map((reply) {
                    return GestureDetector(
                      onTap: () => onTapQuickReply(reply),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              reply,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
