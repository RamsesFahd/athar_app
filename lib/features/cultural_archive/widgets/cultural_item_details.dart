import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class CulturalItemDetails extends StatefulWidget {
  final String id;

  const CulturalItemDetails({super.key, required this.id});

  @override
  State<CulturalItemDetails> createState() => _CulturalItemDetailsState();
}

class _CulturalItemDetailsState extends State<CulturalItemDetails> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final double screenHeight = MediaQuery.of(context).size.height;

    // خريطة بيانات لربط المعرف بالنصوص والصور الصحيحة من ملفات الـ ARB
    final Map<String, Map<String, dynamic>> itemContent = {
      'coffee': {
        'title': loc.coffeeTitle,
        'desc': loc.coffeeDesc,
        'region': loc.reg_riyadh,
        'category': loc.cat_food,
        'image':
            'https://images.pexels.com/photos/1727123/pexels-photo-1727123.jpeg',
      },
      'sadu': {
        'title': loc.saduTitle,
        'desc': loc.saduDesc,
        'region': loc.reg_riyadh, // أو المنطقة المناسبة للسدو
        'category': loc.cat_craft,
        'image':
            'https://images.pexels.com/photos/5505172/pexels-photo-5505172.jpeg',
      },
      'kleija': {
        'title': loc.kleijaTitle,
        'desc': loc.kleijaDesc,
        'region': loc.reg_qassim,
        'category': loc.cat_food,
        'image':
            'https://images.pexels.com/photos/15632126/pexels-photo-15632126.jpeg',
      },
    };

    final currentItem = itemContent[widget.id] ?? itemContent['coffee']!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(screenHeight, isAr, currentItem['image']),
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
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5))
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(theme, currentItem['title']),
                    const SizedBox(height: 8),
                    _buildLocationRow(theme, currentItem['region']),
                    const SizedBox(height: 32),
                    _sectionTitle(loc.descriptionLabel, theme),
                    _bodyText(currentItem['desc'], theme),
                    const SizedBox(height: 24),
                    _sectionTitle(loc.servingLabel, theme),
                    _bodyText(loc.servingDesc, theme),
                    const SizedBox(height: 24),
                    _buildCategoryBadge(theme, currentItem['category']),
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

  Widget _buildCategoryBadge(ThemeData theme, String categoryLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
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