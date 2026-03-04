import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/features/historical_chat/logic/chat_notifier.dart';
import 'package:athar_app/features/historical_chat/logic/chat_repository.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'package:athar_app/core/constants/region_data.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final RegionModel? region; // null يعني شات عام

  const ChatScreen({super.key, this.region});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

    // تحديد مسار الشات (منطقة معينة أو عام)
    final String chatId = widget.region?.regionId ?? 'general';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. عرض الرسائل باستخدام Stream من فيرستور
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: ref
                    .watch(chatRepositoryProvider)
                    .getMessages(userId, chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return _buildEmptyState();
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
            _buildTypingIndicator(),
            // 2. إظهار اختيار المناطق فقط إذا كان الشات عام
            if (widget.region == null) _buildRegionSelectionArea(),

            // 3. منطقة الإدخال وربطها بالـ Notifier
            _buildInputArea(theme),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.region?.nameAr ?? "مجلس راوي العام",
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          widget.region == null
              ? "حياك الله في مجلس راوي.. وش المنطقة اللي ودك نسولف عنها اليوم؟"
              : "يا هلا بك في ${widget.region!.nameAr}.. وش في خاطرك تعرف عن تراثنا؟",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ),
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
          child: Text(
            message,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionSelectionArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("اختر منطقة للتعمق في تراثها:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                  label:
                      Text(region.nameAr, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  onPressed: () {
                    // الانتقال لشات المنطقة المحددة
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

  Widget _buildInputArea(ThemeData theme) {
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
            onPressed: () => _showAttachmentMenu(context),
          ),

          // 2. حقل الإدخال النصي
          Expanded(
            child: TextField(
              controller: _messageController,
              textAlign: TextAlign.right,
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
                    );
              },
              decoration: InputDecoration(
                hintText: "اسأل راوي...",
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
          isLoading
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(strokeWidth: 2)))
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () async {
                      if (_messageController.text.trim().isEmpty) return;
                      final text = _messageController.text;
                      _messageController.clear();
                      await ref
                          .read(chatNotifierProvider.notifier)
                          .sendUserMessage(
                            region: widget.region,
                            text: text,
                          );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // أضيفي هذا الويدجت داخل الـ ListView.builder أو كعنصر إضافي
  Widget _buildTypingIndicator() {
    final isLoading = ref.watch(chatNotifierProvider); //

    if (!isLoading) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200], // نفس لون فقاعة راوي
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("راوي يكتب الآن",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
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
                  Icons.insert_drive_file, "ملف", Colors.blue, () {}),
              _buildAttachmentOption(
                  Icons.camera_alt, "كاميرا", Colors.red, () {}),
              _buildAttachmentOption(Icons.image, "صورة", Colors.purple, () {}),
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
