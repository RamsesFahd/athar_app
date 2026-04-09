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

  const SmartTextContent({
    super.key,
    required this.text,
    required this.isMe,
    this.onTapQuickReply,
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

  Widget _buildRichTextWithTags(String content, BuildContext context, bool isAr,
      List<CulturalItemModel> allItems) {
    final RegExp tagExp = RegExp(r"#[^#]+#");
    final Iterable<RegExpMatch> matches = tagExp.allMatches(content);

    if (matches.isEmpty) return Text(content, style: _textStyle());

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (var match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: content.substring(lastIndex, match.start)));
      }

      final String fullTag = content.substring(match.start, match.end);
      final String cleanTagName = fullTag.replaceAll('#', '').trim();

      spans.add(
        TextSpan(
          text: cleanTagName,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
      spans.add(TextSpan(text: content.substring(lastIndex)));
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
        color: Colors.white,
        fontSize: 15,
        height: 1.5,
      );
}
