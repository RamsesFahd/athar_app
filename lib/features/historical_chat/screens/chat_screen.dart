import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart';
import 'package:athar_app/features/historical_chat/logic/chat_notifier.dart';
import 'package:athar_app/features/historical_chat/logic/chat_repository.dart';
import 'package:athar_app/features/historical_chat/widgets/rawi_suggestion_card.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/chat_message_bubble.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final RegionModel? region; // null يعني شات عام
  final String? existingSessionId;
  const ChatScreen({super.key, this.region, this.existingSessionId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final String _sessionId = widget.existingSessionId ??
      DateTime.now().millisecondsSinceEpoch.toString();

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  late final AnimationController _micPulse;

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.region != null) {
        ref.read(chatNotifierProvider.notifier).sendInitialGreeting(
              region: widget.region!,
              sessionId: _sessionId,
            );
      }
      _initSpeech();
    });
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _toggleListening(bool isAr, AppLocalizations l10n) async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      final available = await _speech.initialize();
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.rawiMicPermissionDenied)),
        );
        return;
      }
      setState(() => _speechAvailable = true);
    }

    setState(() => _isListening = true);

    final localeId = isAr ? 'ar-SA' : 'en-US';
    await _speech.listen(
      localeId: localeId,
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _messageController.text = result.recognizedWords;
          _messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _messageController.text.length),
          );
        }
        if (result.finalResult) {
          setState(() => _isListening = false);
        }
      },
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> _pickAndSendImage(ImageSource source, AppLocalizations l10n) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();

      await ref.read(chatNotifierProvider.notifier).sendUserMessage(
            region: widget.region,
            text: l10n.rawiImageQuestion,
            sessionId: _sessionId,
            imageBytes: imageBytes,
          );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _micPulse.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authRepo = ref.read(authRepositoryProvider);
    final userId = authRepo.currentUser?.uid ?? 'guest_user';

    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  final messages = snapshot.data ?? const <ChatMessageModel>[];

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      messages.isEmpty) {
                    if (widget.region == null) {
                      return _buildGeneralWelcomeWithRegionChips(isAr, l10n);
                    }
                    return const SizedBox.shrink();
                  }

                  if (messages.isEmpty) {
                    if (widget.region == null) {
                      return _buildGeneralWelcomeWithRegionChips(isAr, l10n);
                    }
                    return _buildEmptyState(isAr, l10n);
                  }

                  final firstBotMessageWithSuggestionsId =
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
                          msg.id == firstBotMessageWithSuggestionsId;

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
                              alignment: Alignment.centerLeft,
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
            _buildTypingIndicator(isAr, l10n),
            _buildInputArea(theme, isAr, l10n),
          ],
        ),
        ),
      ),
    );
  }

  String _displaySessionTitle(
    ChatSessionModel session,
    bool isAr,
    AppLocalizations l10n,
  ) {
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
    if (matchedRegion != null) {
      return fallbackTitle;
    }
    if (session.title.isNotEmpty) {
      return session.title;
    }
    return fallbackTitle;
  }

  PreferredSizeWidget _buildAppBar(
    String userId,
    bool isAr,
    AppLocalizations l10n,
  ) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final toolbarExtra =
        ((textScale - 1.0).clamp(0.0, 1.0) * 16).toDouble();
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
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          );
        },
      ),
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEmptyState(bool isAr, AppLocalizations l10n) {
    if (widget.region == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            l10n.rawiWelcomeGeneral,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

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
      final message = messages[i];
      if (message.isUser) {
        continue;
      }
      final parts = _splitMessageContent(message.text);
      if (parts.quickReplies.isNotEmpty) {
        return message.id;
      }
    }
    return null;
  }

  CulturalItemModel? _findCulturalItem(
      List<CulturalItemModel> items, String query) {
    String normalize(String t) => t
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'^(ال)'), '')
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');

    final cleanQuery = normalize(query);
    try {
      return items.firstWhere((item) {
        final nameAr = normalize(item.titleAr);
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
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => AttractionDetailsScreen(attraction: AttractionModel.fromMap(doc.data()!, doc.id)),
          ));
          break;
        case 'trip':
          final doc = await db.collection('trips').doc(id).get();
          if (!doc.exists || doc.data() == null || !mounted) return;
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => TripDetailsScreen(trip: TripModel.fromMap(doc.data()!, doc.id)),
          ));
          break;
        case 'cultural_item':
          final doc = await db.collection('cultural_items').doc(id).get();
          if (!doc.exists || doc.data() == null || !mounted) return;
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => CulturalItemDetails(item: CulturalItemModel.fromMap(doc.data()!, doc.id)),
          ));
          break;
      }
    } catch (_) {}
  }

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
              builder: (_) => CulturalItemDetails(item: archiveItem),
            ),
          );
          return;
        }

        // Search in suggestedItems of this message
        if (suggestedItems != null && suggestedItems.isNotEmpty) {
          final match = _findInSuggestedItems(suggestedItems, entityName);
          if (match != null) {
            _navigateToSuggestedItem(match);
            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? 'لم نجد "$entityName" في الأرشيف'
                  : 'No record for "$entityName"',
            ),
            backgroundColor: const Color(0xFF1B5E20),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Map<String, dynamic>? _findInSuggestedItems(
      List<Map<String, dynamic>> items, String query) {
    String normalize(String t) => t
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'^(ال)'), '')
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');

    final cleanQuery = normalize(query);
    try {
      return items.firstWhere((item) {
        final titleAr = normalize(item['titleAr']?.toString() ?? '');
        final titleEn = (item['titleEn']?.toString() ?? '').toLowerCase().trim();
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

  Widget _buildGeneralWelcomeWithRegionChips(bool isAr, AppLocalizations l10n) {
    final topRegions = regionsData.take(5).toList();

    return ListView(
      reverse: true,
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: topRegions.map((region) {
                final regionName = isAr ? region.nameAr : region.nameEn;
                return GestureDetector(
                  onTap: () async {
                    await ref
                        .read(chatNotifierProvider.notifier)
                        .sendUserMessage(
                          region: null,
                          text: regionName,
                          sessionId: _sessionId,
                        );
                  },
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
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
                            Icons.explore_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.6,
                            ),
                            child: Text(
                              regionName,
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
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.zero,
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
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                l10n.rawiPickRegionStart,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isAr, AppLocalizations l10n) {
    final isLoading = ref.watch(chatNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // زر الزائد (+) لإضافة الوسائط
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 28),
            onPressed: () => _showAttachmentMenu(context, l10n),
          ),
          // حقل الإدخال النصي
          Expanded(
            child: TextField(
              controller: _messageController,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                height: 1.3,
              ),
              cursorColor: AppColors.primary,
              autofocus: true,
              enableSuggestions: true,
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              textAlignVertical: TextAlignVertical.center,
              onSubmitted: (_) async {
                if (_messageController.text.trim().isEmpty) return;
                final text = _messageController.text;
                _messageController.clear();
                await ref.read(chatNotifierProvider.notifier).sendUserMessage(
                      region: widget.region,
                      text: text,
                      sessionId: _sessionId,
                    );
              },
              decoration: InputDecoration(
                hintText: _isListening
                    ? l10n.rawiMicListening
                    : l10n.rawiAskHint,
                hintStyle: TextStyle(
                  color: _isListening ? AppColors.primary : Colors.black45,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // زر الميكروفون
          AnimatedBuilder(
            animation: _micPulse,
            builder: (context, child) {
              return IconButton(
                tooltip: l10n.rawiMicTooltip,
                icon: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isListening
                      ? Color.lerp(
                          AppColors.primary,
                          Colors.red,
                          _micPulse.value,
                        )!
                      : AppColors.primary,
                  size: 26,
                ),
                onPressed: isLoading
                    ? null
                    : () => _toggleListening(isAr, l10n),
              );
            },
          ),

          // زر الإرسال أو مؤشر التحميل
          CircleAvatar(
            radius: 20,
            backgroundColor: isLoading ? Colors.grey[300] : AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_messageController.text.trim().isEmpty) return;
                      final text = _messageController.text;
                      _messageController.clear();
                      if (_isListening) {
                        await _speech.stop();
                        setState(() => _isListening = false);
                      }
                      await ref
                          .read(chatNotifierProvider.notifier)
                          .sendUserMessage(
                            region: widget.region,
                            text: text,
                            sessionId: _sessionId,
                          );
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isAr, AppLocalizations l10n) {
    final isLoading = ref.watch(chatNotifierProvider);

    if (!isLoading) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.zero,
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
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            l10n.rawiTyping,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 12,
            runSpacing: 16,
            children: [
              _buildAttachmentOption(Icons.insert_drive_file,
                  l10n.rawiAttachmentFile, Colors.blue, () {}),
              _buildAttachmentOption(
                  Icons.camera_alt, l10n.rawiAttachmentCamera, Colors.red,
                  () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.camera, l10n);
              }),
              _buildAttachmentOption(
                  Icons.image, l10n.rawiAttachmentImage, Colors.purple, () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.gallery, l10n);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
