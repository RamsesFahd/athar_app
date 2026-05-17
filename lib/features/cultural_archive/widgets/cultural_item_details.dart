import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/favorites/favorite_item_model.dart';
import 'package:athar_app/core/utils/share_utils.dart';
import 'package:athar_app/features/profile/logic/favorites_notifier.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/services/tts_service.dart';

class CulturalItemDetails extends ConsumerStatefulWidget {
  final CulturalItemModel item;

  const CulturalItemDetails({super.key, required this.item});

  @override
  ConsumerState<CulturalItemDetails> createState() =>
      _CulturalItemDetailsState();
}

class _CulturalItemDetailsState extends ConsumerState<CulturalItemDetails> {
  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final double screenHeight = MediaQuery.of(context).size.height;

    final currentItem = widget.item;
    //acc
    final settings = ref.watch(settingsProvider);
    final ttsService = ref.read(ttsServiceProvider);

    final titleText =
    isAr ? currentItem.titleAr : currentItem.titleEn;

    final descriptionText =
    isAr ? currentItem.descriptionAr : currentItem.descriptionEn;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(screenHeight, isAr, currentItem.imageUrl),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5))
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(
                    theme,
                    isAr,
                    titleText,
                    settings.isTtsEnabled
                    ? () => ttsService.speak(
                    '$titleText. $descriptionText'
                     )
                      : null,
                    ),
                    if (currentItem.isContribution) ...[
                      const SizedBox(height: 10),
                      _buildCommunityBadge(
                          theme, isAr, currentItem.contributorName),
                    ],
                    const SizedBox(height: 8),
                    _buildLocationRow(
                      theme,
                      isAr ? currentItem.regionAr : currentItem.regionEn,
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle(l10n.descriptionLabel, theme),
                    _bodyText(
                      isAr
                          ? currentItem.descriptionAr
                          : currentItem.descriptionEn,
                      theme,
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryBadge(theme, currentItem.categoryId, l10n),
                    if (currentItem.isContribution &&
                        currentItem.contributorName != null &&
                        currentItem.contributorName!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildContributorLine(
                          theme, isAr, currentItem.contributorName!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(double height, bool isAr, String imageUrl) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          height: height * 0.45,
          width: double.infinity,
          fit: BoxFit.cover,
          memCacheWidth: 1080,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, __) => const ColoredBox(color: Color(0xFFEEEEEE)),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: Icon(isAr ? Icons.chevron_right : Icons.chevron_left,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(ThemeData theme, bool isAr, String title,VoidCallback? onSpeak) {
    final isFavAsync = ref.watch(isFavoriteProvider(widget.item.id));
    final isFav = isFavAsync.value ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: (theme.textTheme.displayLarge?.fontSize ?? 24) - 4,
            ),
          ),
        ),
        Row(
          children: [
            if (onSpeak != null)
            IconButton(
            onPressed: onSpeak,
            icon: Icon(
            Icons.volume_up_rounded,
            color: theme.colorScheme.primary,
            ),
          ),
            IconButton(
              onPressed: () => ShareUtils.shareCulturalItem(
                context: context,
                titleAr: widget.item.titleAr,
                titleEn: widget.item.titleEn,
                regionAr: widget.item.regionAr,
                regionEn: widget.item.regionEn,
                descriptionAr: widget.item.descriptionAr,
                descriptionEn: widget.item.descriptionEn,
                isAr: isAr,
              ),
              icon: Icon(Icons.share_outlined,
                  color: theme.colorScheme.primary),
            ),
            IconButton(
              onPressed: () => ref
                  .read(favoritesNotifierProvider.notifier)
                  .toggle(FavoriteItemModel.fromCultural(widget.item)),
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(ThemeData theme, String region) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined,
            size: 16, color: theme.colorScheme.secondary),
        const SizedBox(width: 4),
        Text(region, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildCommunityBadge(
      ThemeData theme, bool isAr, String? contributorName) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_alt_outlined,
                  size: 14, color: theme.colorScheme.tertiary),
              const SizedBox(width: 6),
              Text(
                isAr ? 'مساهمة المجتمع' : 'Community Contribution',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(
      ThemeData theme, String categoryLabel, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        categoryLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContributorLine(ThemeData theme, bool isAr, String name) {
    return Row(
      children: [
        Icon(Icons.person_outline, size: 14, color: theme.colorScheme.tertiary),
        const SizedBox(width: 6),
        Text(
          isAr ? 'بقلم: $name' : 'By: $name',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.tertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: theme.textTheme.titleLarge),
    );
  }

  Widget _bodyText(String text, ThemeData theme) {
    return Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6));
  }
}
