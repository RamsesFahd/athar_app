import 'dart:typed_data';
import 'package:athar_app/core/models/chat/region_model.dart';
import 'package:athar_app/features/rawi/logic/chat_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// The bottom input row: text field, microphone, send button, and attachment
/// menu. Owns all speech-recognition state and the text controller so the
/// parent screen stays free of that complexity.
class ChatInputBar extends ConsumerStatefulWidget {
  final RegionModel? region;
  final String sessionId;

  const ChatInputBar({
    super.key,
    required this.region,
    required this.sessionId,
  });

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  late final AnimationController _micPulse;

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _controller.dispose();
    _micPulse.dispose();
    _speech.stop();
    super.dispose();
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
      _micPulse.stop();
      _micPulse.reset();
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
    _micPulse.repeat(reverse: true);

    await _speech.listen(
      localeId: isAr ? 'ar-SA' : 'en-US',
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
        if (result.finalResult) {
          setState(() => _isListening = false);
          _micPulse.stop();
          _micPulse.reset();
        }
      },
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> _pickAndSendImage(
      ImageSource source, AppLocalizations l10n) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    final Uint8List bytes = await image.readAsBytes();
    await ref.read(chatNotifierProvider.notifier).sendUserMessage(
          region: widget.region,
          text: l10n.rawiImageQuestion,
          sessionId: widget.sessionId,
          imageBytes: bytes,
        );
  }

  Future<void> _sendText() async {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text;
    _controller.clear();
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
    await ref.read(chatNotifierProvider.notifier).sendUserMessage(
          region: widget.region,
          text: text,
          sessionId: widget.sessionId,
        );
  }

  void _showAttachmentMenu(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 12,
            runSpacing: 16,
            children: [
              _attachmentOption(
                Icons.insert_drive_file,
                l10n.rawiAttachmentFile,
                Colors.blue,
                () {},
              ),
              _attachmentOption(
                Icons.camera_alt,
                l10n.rawiAttachmentCamera,
                Colors.red,
                () {
                  Navigator.pop(ctx);
                  _pickAndSendImage(ImageSource.camera, l10n);
                },
              ),
              _attachmentOption(
                Icons.image,
                l10n.rawiAttachmentImage,
                Colors.purple,
                () {
                  Navigator.pop(ctx);
                  _pickAndSendImage(ImageSource.gallery, l10n);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentOption(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(chatNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: theme.colorScheme.primary, size: 28),
            onPressed: () => _showAttachmentMenu(l10n),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                height: 1.3,
              ),
              cursorColor: theme.colorScheme.primary,
              autofocus: true,
              enableSuggestions: true,
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              textAlignVertical: TextAlignVertical.center,
              onSubmitted: (_) => _sendText(),
              decoration: InputDecoration(
                hintText:
                    _isListening ? l10n.rawiMicListening : l10n.rawiAskHint,
                hintStyle: TextStyle(
                  color: _isListening
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
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
          AnimatedBuilder(
            animation: _micPulse,
            builder: (context, child) {
              return IconButton(
                tooltip: l10n.rawiMicTooltip,
                icon: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isListening
                      ? Color.lerp(
                          theme.colorScheme.primary,
                          Colors.red,
                          _micPulse.value,
                        )!
                      : theme.colorScheme.primary,
                  size: 26,
                ),
                onPressed:
                    isLoading ? null : () => _toggleListening(isAr, l10n),
              );
            },
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: isLoading
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primary,
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: isLoading
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onPrimary,
                size: 18,
              ),
              onPressed: isLoading ? null : _sendText,
            ),
          ),
        ],
      ),
    );
  }
}
