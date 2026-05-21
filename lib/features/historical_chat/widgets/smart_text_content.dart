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
  final List<Map<String, dynamic>>? suggestedItems;

  const SmartTextContent({
    super.key,
    required this.text,
    required this.isMe,
    this.onTapQuickReply,
    this.onEntityTap,
    this.suggestedItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final culturalState = ref.watch(culturalNotifierProvider);
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Build the set of valid entity names from both archive and message suggestions.
    // Only names in this set will be rendered as tappable entities.
    final Set<String> validEntityNames = {};
    for (final item in culturalState.value?.allItems ?? []) {
      if (item.titleAr.trim().isNotEmpty) validEntityNames.add(item.titleAr.trim());
      if (item.titleEn.trim().isNotEmpty) validEntityNames.add(item.titleEn.trim());
    }
    for (final item in suggestedItems ?? []) {
      final ar = item['titleAr']?.toString().trim() ?? '';
      final en = item['titleEn']?.toString().trim() ?? '';
      if (ar.isNotEmpty) validEntityNames.add(ar);
      if (en.isNotEmpty) validEntityNames.add(en);
    }

    final allLines = text.split('\n');
    final quickReplyLines = allLines.where((line) {
      final t = line.trim();
      return t.startsWith('*') && !t.startsWith('**');
    }).toList();
    final mainText = allLines.where((line) {
      final t = line.trim();
      return !t.startsWith('*') || t.startsWith('**');
    }).join('\n');

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildRichTextWithTags(
            mainText, context, isAr, culturalState.value?.allItems ?? [],
            validEntityNames),

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
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  child: Text(
                    cleanText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                onPressed: () => onTapQuickReply?.call(cleanText),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // Checks whether an entity name matches a known platform item using
  // Arabic-normalized fuzzy matching.
  bool _isKnownEntity(String name, Set<String> validNames) {
    if (validNames.isEmpty) return false;
    final normalized = _normalize(name);
    return validNames.any((v) {
      final nv = _normalize(v);
      return nv == normalized || nv.contains(normalized) || normalized.contains(nv);
    });
  }

  String _normalize(String text) => text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'^(ال)'), '')
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'\s+'), ' ');

  // Parses **bold** text into either a clickable entity span (if the name is a
  // known platform item) or a non-interactive bold span (if not). Also handles
  // *italic* emphasis by stripping the asterisks and rendering as plain text.
  List<InlineSpan> _parseInlineEntities(
      String segment, Set<String> validEntityNames) {
    // Only match **bold** and *italic* — quoted strings are not entity markers.
    final entityExp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
    final matches = entityExp.allMatches(segment);

    if (matches.isEmpty) return [TextSpan(text: segment)];

    final List<InlineSpan> spans = [];
    int last = 0;

    for (final match in matches) {
      if (match.start > last) {
        spans.add(TextSpan(text: segment.substring(last, match.start)));
      }

      final isBold = match.group(1) != null;
      final entityText = (match.group(1) ?? match.group(2) ?? '').trim();

      if (isBold && entityText.isNotEmpty) {
        final isKnown = _isKnownEntity(entityText, validEntityNames);
        spans.add(TextSpan(
          text: entityText,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            // Clickable entities use the primary brand color; unrecognised bold
            // text stays in the default message color so it is not misleadingly
            // interactive.
            color: isKnown ? AppColors.primary : null,
            height: 1.5,
          ),
          recognizer: isKnown
              ? (TapGestureRecognizer()
                ..onTap = () => onEntityTap?.call(entityText))
              : null,
        ));
      } else {
        // *italic* → strip asterisks, render as plain text
        spans.add(TextSpan(text: entityText));
      }

      last = match.end;
    }

    if (last < segment.length) {
      spans.add(TextSpan(text: segment.substring(last)));
    }

    return spans;
  }

  Widget _buildRichTextWithTags(
    String content,
    BuildContext context,
    bool isAr,
    List<CulturalItemModel> allItems,
    Set<String> validEntityNames,
  ) {
    final RegExp tagExp = RegExp(r"#[^#]+#");
    final Iterable<RegExpMatch> matches = tagExp.allMatches(content);

    if (matches.isEmpty) {
      if (isMe) return Text(content, style: _textStyle());
      final spans = _parseInlineEntities(content, validEntityNames);
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
          spans.addAll(_parseInlineEntities(segment, validEntityNames));
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
        spans.addAll(_parseInlineEntities(segment, validEntityNames));
      }
    }

    return RichText(text: TextSpan(style: _textStyle(), children: spans));
  }

  CulturalItemModel? _searchForItem(
      List<CulturalItemModel> items, String query) {
    final String cleanQuery = _normalize(query);

    try {
      return items.firstWhere((item) {
        final String nameAr = _normalize(item.titleAr);
        final String nameEn = item.titleEn.toLowerCase().trim();
        final String qEn = query.toLowerCase().trim();

        return nameAr.contains(cleanQuery) ||
            cleanQuery.contains(nameAr) ||
            nameEn.contains(qEn) ||
            qEn.contains(nameEn);
      });
    } catch (_) {
      return null;
    }
  }

  TextStyle _textStyle() => GoogleFonts.cairo(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 15,
        height: 1.5,
      );
}
