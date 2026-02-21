import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:athar_app/features/home/widgets/recommended_item_card.dart';
import 'package:athar_app/features/home/widgets/recommended_item_details.dart';
import 'package:athar_app/features/home/widgets/explore_heritage_home_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onSeeAllArchive;

  const HomeScreen({
    super.key,
    this.onSeeAllArchive,
  });

  static const double _pageH = 16;
  static const double _sectionGap = 26; // بين السكاشن
  static const double _headerToContent = 16; // بين العنوان والمحتوى

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Stack(
              children: [
                Image.network(
                  'https://images.pexels.com/photos/3290068/pexels-photo-3290068.jpeg',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _pageH,
                  right: _pageH,
                  bottom: 18,
                  child: Text(
                    l10n.homeHeroTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: _sectionGap),

            // Section: You May Like
            _SectionHeader(
              title: l10n.homeYouMayLikeTitle,
              onTap: () {},
            ),

            const SizedBox(height: _headerToContent),

            SizedBox(
              height: 245,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: _pageH),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecommendedItemDetails(
                            title: 'Al-Balad Historic District',
                            titleArabic: 'البلد التاريخي',
                            image:
                                'https://images.pexels.com/photos/3225531/pexels-photo-3225531.jpeg',
                            category: 'Landmark',
                            location: 'Jeddah',
                          ),
                        ),
                      );
                    },
                    child: const RecommendedItemCard(
                      title: 'Al-Balad Historic District',
                      titleArabic: 'البلد التاريخي',
                      image:
                          'https://images.pexels.com/photos/3225531/pexels-photo-3225531.jpeg',
                      category: 'Landmark',
                      location: 'Jeddah',
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecommendedItemDetails(
                            title: 'Najdi Architecture Tour',
                            titleArabic: 'جولة العمارة النجدية',
                            image:
                                'https://images.pexels.com/photos/13126875/pexels-photo-13126875.jpeg',
                            category: 'Tour',
                            location: 'Riyadh',
                          ),
                        ),
                      );
                    },
                    child: const RecommendedItemCard(
                      title: 'Najdi Architecture Tour',
                      titleArabic: 'جولة العمارة النجدية',
                      image:
                          'https://images.pexels.com/photos/13126875/pexels-photo-13126875.jpeg',
                      category: 'Tour',
                      location: 'Riyadh',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: _sectionGap),

            // Section: Explore Saudi Heritage
            _SectionHeader(
              title: l10n.homeExploreHeritageTitle,
              onTap: onSeeAllArchive ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CulturalArchive(),
                      ),
                    );
                  },
            ),

            const SizedBox(height: _headerToContent),

            SizedBox(
              height: 245,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: _pageH),
                children: const [
                  ExploreHeritageHomeCard(
                    title: 'Najdi Coffee Traditions',
                    image:
                        'https://images.pexels.com/photos/2396220/pexels-photo-2396220.jpeg',
                    categoryLabel: 'Food',
                    locationLabel: 'Central Region',
                    onTap: null,
                  ),
                  SizedBox(width: 14),
                  ExploreHeritageHomeCard(
                    title: 'Traditional Sadu Weaving',
                    image:
                        'https://images.pexels.com/photos/6192554/pexels-photo-6192554.jpeg',
                    categoryLabel: 'Craft',
                    locationLabel: 'Various Regions',
                    onTap: null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: _sectionGap),

            // Quick Access
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pageH),
              child: Text(
                l10n.homeQuickAccessTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: _headerToContent),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pageH),
              child: Column(
                children: [
                  _QuickAccessRowTile(
                    title: l10n.quickCalendar,
                    icon: Icons.calendar_today_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _QuickAccessRowTile(
                    title: l10n.quickMap,
                    icon: Icons.explore_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _QuickAccessRowTile(
                    title: l10n.quickAchievements,
                    icon: Icons.emoji_events_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _QuickAccessRowTile(
                    title: l10n.quickGuides,
                    icon: Icons.groups_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: _sectionGap),
          ],
        ),
      ),
    );
  }
}

// Header: Title + See All
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final chevron = isRtl ? Icons.chevron_left : Icons.chevron_right;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeScreen._pageH),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: isRtl
                      ? [
                          Icon(chevron,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            //see all
                            l10n.seeAllLabel,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            l10n.seeAllLabel,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(chevron,
                              size: 18, color: theme.colorScheme.primary),
                        ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

//Quick Access Row Tile
class _QuickAccessRowTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _QuickAccessRowTile({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final chevron = isRtl ? Icons.chevron_left : Icons.chevron_right;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Icon(
                chevron,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
