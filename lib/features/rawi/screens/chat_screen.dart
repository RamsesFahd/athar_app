import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart';
import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/widgets/chat_message_bubble.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/features/rawi/logic/chat_notifier.dart';
import 'package:athar_app/features/rawi/logic/chat_repository.dart';
import 'package:athar_app/features/rawi/widgets/chat_input_bar.dart';
import 'package:athar_app/features/rawi/widgets/chat_typing_indicator.dart';
import 'package:athar_app/features/rawi/widgets/rawi_suggestion_card.dart';
import 'package:athar_app/features/rawi/widgets/region_welcome_chips.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final RegionModel? region;
  final String? existingSessionId;

  const ChatScreen({super.key, this.region, this.existingSessionId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late final String _sessionId = widget.existingSessionId ??
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.region != null) {
        ref.read(chatNotifierProvider.notifier).sendInitialGreeting(
              region: widget.region!,
              sessionId: _sessionId,
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final userId =
        ref.read(authRepositoryProvider).currentUser?.uid ?? 'guest_user';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(userId, isAr, l10n),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessageModel>>(
                  stream: ref
                      .watch(chatRepositoryProvider)
                      .getMessages(userId, _sessionId),
                  builder: (context, snapshot) {
                    final messages =
                        snapshot.data ?? const <ChatMessageModel>[];

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        messages.isEmpty) {
                      return widget.region == null
                          ? RegionWelcomeChips(
                              isAr: isAr, sessionId: _sessionId)
                          : const SizedBox.shrink();
                    }

                    if (messages.isEmpty) {
                      return widget.region == null
                          ? RegionWelcomeChips(
                              isAr: isAr, sessionId: _sessionId)
                          : const SizedBox.shrink();
                    }

                    final firstBotWithSuggestionsId =
                        _findFirstBotMessageWithSuggestions(messages);

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final showQuickReplies = widget.region != null &&
                            !msg.isUser &&
                            msg.id != null &&
                            msg.id == firstBotWithSuggestionsId;
                        final hasSuggestions = !msg.isUser &&
                            msg.suggestedItems != null &&
                            msg.suggestedItems!.isNotEmpty;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMessageBubble(
                              message: msg.text,
                              isMe: msg.isUser,
                              showQuickReplies: showQuickReplies,
                              isAr: isAr,
                              suggestedItems: msg.suggestedItems,
                            ),
                            if (hasSuggestions)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: RawiSuggestionsRow(
                                  items: msg.suggestedItems!,
                                  isAr: isAr,
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              ChatTypingIndicator(isAr: isAr),
              ChatInputBar(region: widget.region, sessionId: _sessionId),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      String userId, bool isAr, AppLocalizations l10n) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final toolbarExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 16).toDouble();
    final defaultTitle = isAr
        ? (widget.region?.nameAr ?? l10n.rawiGeneralCouncil)
        : (widget.region?.nameEn ?? l10n.rawiGeneralCouncil);

    return AppBar(
      toolbarHeight: 56 + toolbarExtra,
      title: StreamBuilder<ChatSessionModel?>(
        stream:
            ref.watch(chatRepositoryProvider).watchSession(userId, _sessionId),
        builder: (context, snapshot) {
          final title = snapshot.hasData && snapshot.data != null
              ? _displaySessionTitle(snapshot.data!, isAr, l10n)
              : defaultTitle;
          return Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          );
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0.5,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  String _displaySessionTitle(
      ChatSessionModel session, bool isAr, AppLocalizations l10n) {
    RegionModel? matchedRegion;
    for (final region in regionsData) {
      if (region.regionId == session.regionId) {
        matchedRegion = region;
        break;
      }
    }

    final hasLocalizedTitle =
        session.titleAr.isNotEmpty || session.titleEn.isNotEmpty;
    final localizedTitle = session.localizedTitle(isAr ? 'ar' : 'en');
    final fallbackTitle = isAr
        ? (matchedRegion != null
            ? l10n.rawiStoryAboutRegion(matchedRegion.nameAr)
            : l10n.rawiUntitledArabic)
        : (matchedRegion != null
            ? l10n.rawiStoryAboutRegion(matchedRegion.nameEn)
            : l10n.rawiUntitledEnglish);

    if (hasLocalizedTitle) {
      return localizedTitle.isNotEmpty ? localizedTitle : fallbackTitle;
    }
    if (matchedRegion != null) return fallbackTitle;
    if (session.title.isNotEmpty) return session.title;
    return fallbackTitle;
  }

  // ── Message rendering ─────────────────────────────────────────────────────

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    required bool showQuickReplies,
    required bool isAr,
    List<Map<String, dynamic>>? suggestedItems,
  }) {
    return ChatMessageBubble(
      message: message,
      isMe: isMe,
      showQuickReplies: showQuickReplies,
      isAr: isAr,
      suggestedItems: suggestedItems,
      onTapQuickReply: (reply) async {
        await ref.read(chatNotifierProvider.notifier).sendUserMessage(
              region: widget.region,
              text: reply,
              sessionId: _sessionId,
            );
      },
      onEntityTap: (entityName) {
        final allItems =
            ref.read(culturalNotifierProvider).value?.allItems ?? [];
        final archiveItem = _findCulturalItem(allItems, entityName);
        if (archiveItem != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CulturalItemDetails(item: archiveItem)),
          );
          return;
        }

        if (suggestedItems != null && suggestedItems.isNotEmpty) {
          final match = _findInSuggestedItems(suggestedItems, entityName);
          if (match != null) {
            _navigateToSuggestedItem(match);
            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).rawiEntityNotFound(entityName)),
          backgroundColor: const Color(0xFF1B5E20),
          duration: const Duration(seconds: 2),
        ));
      },
    );
  }

  // ── Utility helpers ───────────────────────────────────────────────────────

  ({String mainText, List<String> quickReplies}) _splitMessageContent(
      String message) {
    final allLines = message.split('\n');
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

  String? _findFirstBotMessageWithSuggestions(List<ChatMessageModel> messages) {
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (msg.isUser) continue;
      if (_splitMessageContent(msg.text).quickReplies.isNotEmpty) {
        return msg.id;
      }
    }
    return null;
  }

  static String _normalizeArabic(String t) => t
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'^(ال)'), '')
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'\s+'), ' ');

  CulturalItemModel? _findCulturalItem(
      List<CulturalItemModel> items, String query) {
    final cleanQuery = _normalizeArabic(query);
    try {
      return items.firstWhere((item) {
        final nameAr = _normalizeArabic(item.titleAr);
        final nameEn = item.titleEn.toLowerCase().trim();
        final qEn = query.toLowerCase().trim();
        return nameAr.contains(cleanQuery) ||
            cleanQuery.contains(nameAr) ||
            nameEn.contains(qEn) ||
            qEn.contains(nameEn);
      });
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _findInSuggestedItems(
      List<Map<String, dynamic>> items, String query) {
    final cleanQuery = _normalizeArabic(query);
    try {
      return items.firstWhere((item) {
        final titleAr = _normalizeArabic(item['titleAr']?.toString() ?? '');
        final titleEn =
            (item['titleEn']?.toString() ?? '').toLowerCase().trim();
        final qEn = query.toLowerCase().trim();
        return titleAr.contains(cleanQuery) ||
            cleanQuery.contains(titleAr) ||
            titleEn.contains(qEn) ||
            qEn.contains(titleEn);
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> _navigateToSuggestedItem(Map<String, dynamic> item) async {
    final id = item['id']?.toString() ?? '';
    final type = item['type']?.toString() ?? '';
    if (id.isEmpty || type.isEmpty) return;
    final db = FirebaseFirestore.instance;
    try {
      switch (type) {
        case 'attraction':
          final doc = await db.collection('attractions').doc(id).get();
          if (!doc.exists || doc.data() == null || !mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AttractionDetailsScreen(
                      attraction:
                          AttractionModel.fromMap(doc.data()!, doc.id))));
          break;
        case 'trip':
          final doc = await db.collection('trips').doc(id).get();
          if (!doc.exists || doc.data() == null || !mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TripDetailsScreen(
                      trip: TripModel.fromMap(doc.data()!, doc.id))));
          break;
        case 'cultural_item':
          final doc = await db.collection('cultural_items').doc(id).get();
          if (!doc.exists || doc.data() == null || !mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CulturalItemDetails(
                      item: CulturalItemModel.fromMap(doc.data()!, doc.id))));
          break;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).commonErrorWithMessage(''))));
    }
  }
}
