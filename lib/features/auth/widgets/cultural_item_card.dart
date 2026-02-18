import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

enum CardLayout { vertical, horizontal }

class CulturalItemCard extends StatelessWidget {
  final String id;
  final String image;
  final String category;
  final String region;
  final CardLayout layout;

  const CulturalItemCard({
    super.key,
    required this.id,
    required this.image,
    required this.category,
    required this.region,
    this.layout = CardLayout.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final Map<String, Map<String, String>> localizedContent = {
      'coffee': {
        'title': loc.coffeeTitle,
        'desc': loc.coffeeDesc,
      },
      'sadu': {
        'title': loc.saduTitle,
        'desc': loc.saduDesc,
      },
      'kleija': {
        'title': loc.kleijaTitle,
        'desc': loc.kleijaDesc,
      },
    };

    final String displayTitle = localizedContent[id]?['title'] ?? id;
    final String displayDescription = localizedContent[id]?['desc'] ?? '';

    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, '/cultural-details', arguments: id),
      child: layout == CardLayout.horizontal
          ? _buildHorizontalLayout(
              displayTitle, displayDescription, isArabic, theme, loc)
          : _buildVerticalLayout(displayTitle, isArabic, theme, loc),
    );
  }

  Widget _buildVerticalLayout(
      String title, bool isAr, ThemeData theme, AppLocalizations loc) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(image,
                height: 120, width: 180, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          _buildBadges(theme, loc),
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
      ThemeData theme, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(image,
                width: 110, height: 110, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBadges(theme, loc),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
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

  Widget _buildBadges(ThemeData theme, AppLocalizations loc) {
    return Wrap(
      spacing: 4,
      children: [
        _badgeTemplate(
          _getTranslatedCategory(category, loc),
          theme.colorScheme.primary.withOpacity(0.12),
          theme.colorScheme.primary,
        ),
        _badgeTemplate(
          _getTranslatedRegion(region, loc),
          theme.colorScheme.secondary.withOpacity(0.12),
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

  String _getTranslatedCategory(String cat, AppLocalizations loc) {
    switch (cat.toLowerCase()) {
      case 'food':
        return loc.cat_food;
      case 'craft':
        return loc.cat_craft;
      case 'music':
        return loc.cat_music;
      case 'dance':
        return loc.cat_dance;
      case 'architecture':
        return loc.cat_architecture;
      case 'clothing':
        return loc.cat_clothing;
      default:
        return cat;
    }
  }

  String _getTranslatedRegion(String reg, AppLocalizations loc) {
    switch (reg.toLowerCase()) {
      case 'riyadh':
        return loc.reg_riyadh;
      case 'makkah':
      case 'mecca':
        return loc.reg_makkah;
      case 'medina':
        return loc.reg_medina;
      case 'eastern':
      case 'eastern province':
        return loc.reg_eastern;
      case 'qassim':
        return loc.reg_qassim;
      case 'asir':
        return loc.reg_asir;
      default:
        return reg;
    }
  }
}
