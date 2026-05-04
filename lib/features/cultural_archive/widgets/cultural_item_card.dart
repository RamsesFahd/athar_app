import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

enum CardLayout { vertical, horizontal }

class CulturalItemCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String categoryId;
  final String region;
  final CardLayout layout;
  final String title;
  final String description;
  final CulturalItemModel item;

  const CulturalItemCard({
    super.key,
    required this.id,
    required this.item,
    required this.imageUrl,
    required this.categoryId,
    required this.region,
    required this.title,
    required this.description,
    this.layout = CardLayout.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final String displayTitle = title;
    final String displayDescription = description;

    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, '/cultural-details', arguments: item),
      child: layout == CardLayout.horizontal
          ? _buildHorizontalLayout(
              displayTitle, displayDescription, isArabic, theme, l10n)
          : _buildVerticalLayout(displayTitle, isArabic, theme, l10n),
    );
  }

  Widget _buildVerticalLayout(
      String title, bool isAr, ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(imageUrl,
                height: 120, width: 180, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          _buildBadges(theme, l10n),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(String title, String desc, bool isAr,
      ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              // حل لمشكلة الـ 404 اللي تطلع بالكونسول
              errorBuilder: (context, error, stackTrace) => Container(
                width: 110,
                height: 110,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBadges(theme, l10n),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                  maxLines: 1, // يمنع النص من القفز لسطر جديد وتخريب الارتفاع
                  overflow:
                      TextOverflow.ellipsis, // يضيف نقاط (...) لو النص طويل
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(ThemeData theme, AppLocalizations l10n) {
    return Wrap(
      spacing: 4,
      children: [
        _badgeTemplate(
          _getTranslatedCategory(categoryId, l10n),
          theme.colorScheme.primary.withValues(alpha: 0.12),
          theme.colorScheme.primary,
        ),
        _badgeTemplate(
          _getTranslatedRegion(region, l10n),
          theme.colorScheme.secondary.withValues(alpha: 0.12),
          theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _badgeTemplate(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  String _getTranslatedCategory(String cat, AppLocalizations l10n) {
    switch (cat.toLowerCase()) {
      case 'food':
        return l10n.cat_food;
      case 'craft':
        return l10n.cat_craft;
      case 'music':
        return l10n.cat_music;
      case 'dance':
        return l10n.cat_dance;
      case 'architecture':
        return l10n.cat_architecture;
      case 'clothing':
        return l10n.cat_clothing;
      default:
        return cat;
    }
  }

  String _getTranslatedRegion(String reg, AppLocalizations l10n) {
    switch (reg.toLowerCase()) {
      case 'riyadh':
        return l10n.reg_riyadh;
      case 'makkah':
      case 'mecca':
        return l10n.reg_makkah;
      case 'medina':
        return l10n.reg_medina;
      case 'eastern':
      case 'eastern province':
        return l10n.reg_eastern;
      case 'qassim':
        return l10n.reg_qassim;
      case 'asir':
        return l10n.reg_asir;
      default:
        return reg;
    }
  }
}
