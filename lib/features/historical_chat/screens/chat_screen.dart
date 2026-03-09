import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart';
import 'package:athar_app/features/historical_chat/logic/chat_notifier.dart';
import 'package:athar_app/features/historical_chat/logic/chat_repository.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/chat_message_bubble.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final RegionModel? region; // null يعني شات عام
  final String? existingSessionId;
  const ChatScreen({super.key, this.region, this.existingSessionId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final String _sessionId = widget.existingSessionId ??
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    // نطلب من راوي يرحب بالمستخدم أول ما تفتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.region != null) {
        ref.read(chatNotifierProvider.notifier).sendInitialGreeting(
              region: widget.region!,
              sessionId: _sessionId,
            );
      }
    });
  }

  Future<void> _pickAndSendImage(ImageSource source, bool isAr) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: source); // هنا بيفتح المصدر اللي نحدده

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();

      await ref.read(chatNotifierProvider.notifier).sendUserMessage(
            region: widget.region,
            text: isAr
                ? "يا راوي، وش تمثل الصورة؟"
                : "Rawi, what does this image represent?",
            sessionId: _sessionId,
            imageBytes: imageBytes,
          );
    }
  }

  bool _containsArabic(String value) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(value);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authRepo = ref.read(authRepositoryProvider);
    final userId = authRepo.currentUser?.uid ?? 'guest_user';

    // تعريفات اللغة والمترجم لاستخدامها في الدوال بالأسفل
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(userId, isAr, l10n),
      body: SafeArea(
        child: Column(
          children: [
            // 1. عرض الرسائل باستخدام Stream من فيرستور
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: ref
                    .watch(chatRepositoryProvider)
                    .getMessages(userId, _sessionId),
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? const <ChatMessageModel>[];

                  // Keep the current UI while the stream is reconnecting/loading
                  // to avoid a visible page "refresh" flicker.
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      messages.isEmpty) {
                    if (widget.region == null) {
                      return _buildGeneralWelcomeWithRegionChips(isAr);
                    }
                    return const SizedBox.shrink();
                  }

                  if (messages.isEmpty) {
                    if (widget.region == null) {
                      return _buildGeneralWelcomeWithRegionChips(isAr);
                    }
                    return _buildEmptyState(isAr, l10n);
                  }

                  final firstBotMessageWithSuggestionsId =
                      _findFirstBotMessageWithSuggestions(messages);

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // الرسائل الجديدة تظهر تحت
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final showQuickReplies = widget.region != null &&
                          !msg.isUser &&
                          msg.id != null &&
                          msg.id == firstBotMessageWithSuggestionsId;

                      return _buildMessageBubble(
                        message: msg.text,
                        isMe: msg.isUser,
                        showQuickReplies: showQuickReplies,
                        isAr: isAr,
                      );
                    },
                  );
                },
              ),
            ),
            _buildTypingIndicator(isAr, l10n),

            // 3. منطقة الإدخال وربطها بالـ Notifier
            _buildInputArea(theme, isAr, l10n),
          ],
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
            ? 'سالفة عن ${matchedRegion.nameAr}'
            : l10n.rawiUntitledArabic)
        : (matchedRegion != null
            ? 'Story about ${matchedRegion.nameEn}'
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
    final defaultTitle = isAr
        ? (widget.region?.nameAr ?? "مجلس راوي العام")
        : (widget.region?.nameEn ?? "Rawi General Council");

    return AppBar(
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
            isAr
                ? "حياك الله في مجلس راوي.. وش المنطقة اللي ودك نسولف عنها اليوم؟"
                : "Welcome to Rawi's Council.. Which region would you like to explore today?",
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

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    required bool showQuickReplies,
    required bool isAr,
  }) {
    return ChatMessageBubble(
      message: message,
      isMe: isMe,
      showQuickReplies: showQuickReplies,
      isAr: isAr,
      onTapQuickReply: (reply) async {
        await ref.read(chatNotifierProvider.notifier).sendUserMessage(
              region: widget.region,
              text: reply,
              sessionId: _sessionId,
            );
      },
    );
  }

  Widget _buildGeneralWelcomeWithRegionChips(bool isAr) {
    final topRegions = regionsData.take(5).toList();

    return ListView(
      reverse: true,
      padding: const EdgeInsets.all(16),
      children: [
        Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Align(
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 6, end: 6, bottom: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topRegions.map((region) {
                  final regionName = isAr ? region.nameAr : region.nameEn;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(region: region)),
                      );
                    },
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
                            Icons.explore_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            regionName,
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Directionality(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                isAr
                    ? 'حياك الله في مجلس راوي.. اختر منطقة نبدأ منها:'
                    : "Welcome to Rawi's Council.. Pick a region to start:",
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
          // 1. زر الزائد (+) لإضافة الوسائط
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 28),
            onPressed: () => _showAttachmentMenu(context, isAr),
          ),
          // 2. حقل الإدخال النصي
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
                hintText: isAr ? "اسأل راوي..." : "Ask Rawi...",
                hintStyle: const TextStyle(
                  color: Colors.black45,
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

          // 3. زر التسجيل الصوتي
          IconButton(
            icon: Icon(Icons.mic_none_rounded,
                color: AppColors.primary, size: 26),
            onPressed: () {
              // منطق بدء التسجيل الصوتي سيضاف هنا
            },
          ),

          // 4. زر الإرسال أو مؤشر التحميل
          CircleAvatar(
            radius: 20,
            // يتغير اللون لرمادي باهت وقت التحميل ليعطي إيحاء بالتعطيل
            backgroundColor: isLoading ? Colors.grey[300] : AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              // السر هنا: جعل onPressed تساوي null يعطل الزر تلقائياً ويمنع الـ "فصل"
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_messageController.text.trim().isEmpty) return;
                      final text = _messageController.text;
                      _messageController.clear();

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

  // أضيفي هذا الويدجت داخل الـ ListView.builder أو كعنصر إضافي
  Widget _buildTypingIndicator(bool isAr, AppLocalizations l10n) {
    final isLoading = ref.watch(chatNotifierProvider);

    // إذا ما فيه تحميل، لا تظهر شيء
    if (!isLoading) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft, // جهة راوي (اليسار)
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, // خلفية بيضاء مثل رسائل راوي
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.zero, // زاوية حادة لجهة اليسار
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
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            isAr ? "راوي يكتب الآن..." : "Rawi is typing...",
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

  void _showAttachmentMenu(BuildContext context, bool isAr) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttachmentOption(Icons.insert_drive_file,
                  isAr ? "ملف" : "File", Colors.blue, () {}),
              _buildAttachmentOption(
                  Icons.camera_alt, isAr ? "كاميرا" : "Camera", Colors.red, () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.camera, isAr);
              }),
              _buildAttachmentOption(
                  Icons.image, isAr ? "صورة" : "Image", Colors.purple, () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.gallery, isAr);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
