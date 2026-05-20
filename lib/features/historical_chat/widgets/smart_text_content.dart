import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../cultural_archive/widgets/cultural_item_details.dart';
import '../../cultural_archive/logic/cultural_notifier.dart';
import '../../../core/models/cultural/cultural_item_model.dart';

class SmartTextContent extends ConsumerWidget {
  final String text;
  final bool isMe;
  final Function(String)? onTapQuickReply;
  final void Function(String entityName)? onEntityTap;

  const SmartTextContent({
    super.key,
    required this.text,
    required this.isMe,
    this.onTapQuickReply,
    this.onEntityTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //  مراقبة الحالة لضمان تحديث الواجهة فور وصول البيانات
    final culturalState = ref.watch(culturalNotifierProvider);
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    final allLines = text.split('\n');
    final quickReplyLines =
        allLines.where((line) => line.trim().startsWith('*')).toList();
    final mainText =
        allLines.where((line) => !line.trim().startsWith('*')).join('\n');

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        //  تمرير البيانات المحملة (إن وجدت) للدالة
        _buildRichTextWithTags(
            mainText, context, isAr, culturalState.value?.allItems ?? []),

        if (quickReplyLines.isNotEmpty && !isMe) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickReplyLines.map((line) {
              final cleanText = line.trim().substring(1).trim();
              return ActionChip(
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: Colors.grey[100],
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                label: Text(
                  cleanText,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () {
                  if (onTapQuickReply != null) {
                    onTapQuickReply!(cleanText);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // Parses **bold**, *italic*, and "quoted" entities into clickable styled spans.
  // Only called for Rawi (isMe == false) messages.
  List<InlineSpan> _parseInlineEntities(String segment) {
    final entityExp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*|"([^"]+)"');
    final matches = entityExp.allMatches(segment);

    if (matches.isEmpty) return [TextSpan(text: segment)];

    final List<InlineSpan> spans = [];
    int last = 0;

    for (final match in matches) {
      if (match.start > last) {
        spans.add(TextSpan(text: segment.substring(last, match.start)));
      }
      final entityText =
          match.group(1) ?? match.group(2) ?? match.group(3) ?? '';
      spans.add(
        TextSpan(
          text: entityText,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            decoration: TextDecoration.underline,
            height: 1.5,
          ),
          // Recognizer lifecycle intentionally matches the existing #tag# pattern.
          // Convert to StatefulWidget if explicit dispose() is required.
          recognizer: TapGestureRecognizer()
            ..onTap = () => onEntityTap?.call(entityText),
        ),
      );
      last = match.end;
    }

    if (last < segment.length) {
      spans.add(TextSpan(text: segment.substring(last)));
    }

    return spans;
  }

  Widget _buildRichTextWithTags(String content, BuildContext context, bool isAr,
      List<CulturalItemModel> allItems) {
    final RegExp tagExp = RegExp(r"#[^#]+#");
    final Iterable<RegExpMatch> matches = tagExp.allMatches(content);

    if (matches.isEmpty) {
      if (isMe) return Text(content, style: _textStyle());
      final spans = _parseInlineEntities(content);
      return RichText(text: TextSpan(style: _textStyle(), children: spans));
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (var match in matches) {
      if (match.start > lastIndex) {
        final segment = content.substring(lastIndex, match.start);
        if (isMe) {
          spans.add(TextSpan(text: segment));
        } else {
          spans.addAll(_parseInlineEntities(segment));
        }
      }

      final String fullTag = content.substring(match.start, match.end);
      final String cleanTagName = fullTag.replaceAll('#', '').trim();

      spans.add(
        TextSpan(
          text: cleanTagName,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isMe ? Colors.white : AppColors.primary,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final matchedItem = _searchForItem(allItems, cleanTagName);

              if (matchedItem != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CulturalItemDetails(item: matchedItem),
                  ),
                );
              } else {
                final String message = allItems.isEmpty
                    ? (isAr
                        ? 'جاري جلب بيانات الأرشيف...'
                        : 'Loading archive...')
                    : (isAr
                        ? 'لم نجد $cleanTagName في الأرشيف'
                        : 'No record for $cleanTagName');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: const Color(0xFF1B5E20),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      final segment = content.substring(lastIndex);
      if (isMe) {
        spans.add(TextSpan(text: segment));
      } else {
        spans.addAll(_parseInlineEntities(segment));
      }
    }

    return RichText(text: TextSpan(style: _textStyle(), children: spans));
  }

  CulturalItemModel? _searchForItem(
      List<CulturalItemModel> items, String query) {
    /// Standardizes Arabic text by removing common variations to ensure consistent matching.
    String normalize(String text) {
      return text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'^(ال)'), '')
          .replaceAll(RegExp(r'[أإآ]'), 'ا')
          .replaceAll('ة', 'ه')
          .replaceAll('ى', 'ي')
          .replaceAll(RegExp(r'\s+'), ' ');
    }

    final String cleanQuery = normalize(query);

    try {
      return items.firstWhere((item) {
        final String nameAr = normalize(item.titleAr);
        final String nameEn = item.titleEn.toLowerCase().trim();
        final String qEn = query.toLowerCase().trim();

        /// Implements bi-directional fuzzy matching to handle descriptive titles and multi-language support.
        return nameAr.contains(cleanQuery) ||
            cleanQuery.contains(nameAr) ||
            nameEn.contains(qEn) ||
            qEn.contains(nameEn);
      });
    } catch (_) {
      return null; // Gracefully handle cases where no cultural item matches the tag.
    }
  }

  TextStyle _textStyle() => GoogleFonts.cairo(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 15,
        height: 1.5,
      );
}
