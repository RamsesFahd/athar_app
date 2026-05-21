import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/historical_chat/widgets/smart_text_content.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool showQuickReplies;
  final bool isAr;
  final ValueChanged<String> onTapQuickReply;
  final void Function(String entityName)? onEntityTap;
  final List<Map<String, dynamic>>? suggestedItems;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showQuickReplies,
    required this.isAr,
    required this.onTapQuickReply,
    this.onEntityTap,
    this.suggestedItems,
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
    final arabicRegex = RegExp(r'[؀-ۿݐ-ݿࢠ-ࣿ]');
    return arabicRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final parts = _splitMessageContent(message);

    // For bot messages, use the app locale so the response always renders in
    // the correct direction even when it contains Arabic entity names inline.
    // For user messages, detect from the actual content to handle users who
    // type in a language different from their app locale.
    final bool isArabic = isMe ? _containsArabic(parts.mainText) : isAr;

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
                color: isMe ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Directionality(
                textDirection:
                    isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: SmartTextContent(
                  text: parts.mainText,
                  isMe: isMe,
                  onEntityTap: onEntityTap,
                  suggestedItems: suggestedItems,
                ),
              ),
            ),
          ),
        if (!isMe && visibleQuickReplies.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: visibleQuickReplies.map((reply) {
                  return GestureDetector(
                    onTap: () => onTapQuickReply(reply),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.66,
                            ),
                            child: Text(
                              reply,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
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
      ],
    );
  }
}
