import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';

class CulturalItemDetails extends StatefulWidget {
  final CulturalItemModel item;

  const CulturalItemDetails({super.key, required this.item});

  @override
  State<CulturalItemDetails> createState() => _CulturalItemDetailsState();
}

class _CulturalItemDetailsState extends State<CulturalItemDetails> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final double screenHeight = MediaQuery.of(context).size.height;

    final currentItem = widget.item;

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
                        color: Colors.black.withValues(alpha:0.05),
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
                      isAr ? currentItem.titleAr : currentItem.titleEn,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationRow(theme,
                    isAr? currentItem.regionAr : currentItem.regionEn,
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
                    _buildCategoryBadge(theme, currentItem.categoryId, l10n)
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
        Image.network(
          imageUrl,
          height: height * 0.45,
          width: double.infinity,
          fit: BoxFit.cover,
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

  Widget _buildTitleSection(ThemeData theme, String title) {
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
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.share_outlined,
                    color: theme.colorScheme.primary)),
            IconButton(
              onPressed: () => setState(() => isFavorite = !isFavorite),
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : theme.colorScheme.primary),
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

  Widget _buildCategoryBadge(ThemeData theme, String categoryLabel, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha:0.1),
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