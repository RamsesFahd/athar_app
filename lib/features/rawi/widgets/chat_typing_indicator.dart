import 'package:athar_app/features/rawi/logic/chat_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a "Rawi is typing…" bubble while the AI is generating a reply.
/// Returns an empty widget when the chat is idle.
class ChatTypingIndicator extends ConsumerWidget {
  final bool isAr;

  const ChatTypingIndicator({super.key, required this.isAr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(chatNotifierProvider);
    if (!isLoading) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            l10n.rawiTyping,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
