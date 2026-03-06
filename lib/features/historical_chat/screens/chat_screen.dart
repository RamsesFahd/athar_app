import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/features/historical_chat/logic/chat_notifier.dart';
import 'package:athar_app/features/historical_chat/logic/chat_repository.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/features/historical_chat/widgets/smart_text_content.dart';
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
  late final String _sessionId = widget.existingSessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

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

  Future<void> _pickAndSendImage(ImageSource source , bool isAr) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source); // هنا بيفتح المصدر اللي نحدده

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      
      await ref.read(chatNotifierProvider.notifier).sendUserMessage(
            region: widget.region,
            text: isAr ? "يا راوي، وش تمثل الصورة؟" : "Rawi, what does this image represent?",
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

    // تحديد مسار الشات (منطقة معينة أو عام)
    final String chatId = widget.region?.regionId ?? 'general';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(isAr, l10n),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return _buildEmptyState(isAr, l10n);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // الرسائل الجديدة تظهر تحت
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageBubble(
                        message: msg.text,
                        isMe: msg.isUser,
                      );
                    },
                  );
                },
              ),
            ),
            _buildTypingIndicator(isAr, l10n),
            // 2. إظهار اختيار المناطق فقط إذا كان الشات عام
            if (widget.region == null) _buildRegionSelectionArea(isAr, l10n),

            // 3. منطقة الإدخال وربطها بالـ Notifier
            _buildInputArea(theme, isAr, l10n),
          ],
        ),
      ),
    );
  }

 PreferredSizeWidget _buildAppBar(bool isAr, AppLocalizations l10n) {

  return AppBar(
    title: Text(
      isAr
          ? (widget.region?.nameAr ?? "مجلس راوي العام")
          : (widget.region?.nameEn ?? "Rawi General Council"),
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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

  return const Center(
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}

  Widget _buildMessageBubble({required String message, required bool isMe}) {
    final isArabic = _containsArabic(message);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
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
                offset: const Offset(0, 2)),
          ],
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          // التعديل هنا: استبدلنا Text بـ SmartTextContent لتنفيذ "محلل النصوص الذكي"
          child: SmartTextContent(
            text: message,
            isMe: isMe,
            onTapQuickReply: (quickReplyText) async {
              await ref.read(chatNotifierProvider.notifier).sendUserMessage(
                    region: widget.region,
                    text: quickReplyText,
                    sessionId: _sessionId,
                  );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRegionSelectionArea(bool isAr, AppLocalizations l10n) {

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          isAr ? "اختر منطقة للتعمق في تراثها:" : "Select a region to explore its heritage:",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
        ),
      ),
      Container(
        height: 45,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: regionsData.length,
          itemBuilder: (context, index) {
            final region = regionsData[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                label: Text(
                  isAr ? region.nameAr : region.nameEn, // هنا السحر، يغير الاسم حسب اللغة
                  style: const TextStyle(fontSize: 12)
                ),
                backgroundColor: Colors.white,
                side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(region: region)),
                  );
                },
              ),
            );
          },
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
                      
                      await ref.read(chatNotifierProvider.notifier).sendUserMessage(
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // نص يشير للحالة
              Text(
                isAr ? "راوي يكتب الآن..." : "Rawi is typing...",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary.withOpacity(0.4)),
                ),
              ),
            ],
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
              _buildAttachmentOption(
                  Icons.insert_drive_file, 
                isAr ? "ملف" : "File",
                Colors.blue, () {}),
              _buildAttachmentOption(
                 Icons.camera_alt, 
                isAr ? "كاميرا" : "Camera", 
                Colors.red, () {
                  Navigator.pop(context);
                  _pickAndSendImage(ImageSource.camera, isAr); 
                }),
              _buildAttachmentOption(
                Icons.image, 
                isAr ? "صورة" : "Image", 
                Colors.purple, () {
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
