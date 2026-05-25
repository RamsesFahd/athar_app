import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/features/rawi/logic/chat_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Welcome screen shown when the general chat has no messages yet.
/// Displays a greeting bubble and region-chip shortcuts so the user can
/// quickly start a region-focused conversation.
class RegionWelcomeChips extends ConsumerWidget {
  final bool isAr;
  final String sessionId;

  const RegionWelcomeChips({
    super.key,
    required this.isAr,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
                          sessionId: sessionId,
                        );
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.explore_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: Text(
                            regionName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
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
                l10n.rawiPickRegionStart,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
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
}
