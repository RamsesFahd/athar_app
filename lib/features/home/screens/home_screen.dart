import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/features/home/widgets/explore_heritage_home_card.dart';
import 'package:athar_app/features/home/widgets/home_hero_slider.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/attractions/screens/attractions_list_screen.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';
import 'package:athar_app/features/guide_market/logic/trips_repository.dart';
import 'package:athar_app/features/guide_market/screens/trips_list_screen.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/features/events/logic/events_repository.dart';
import 'package:athar_app/features/home/logic/recommendations_repository.dart';
import 'package:athar_app/core/models/home/recommended_item.dart';

// PERFORMANCE OPTIMIZATION: HomeScreen converted from ConsumerWidget to
// StatelessWidget. Each carousel section is now its own ConsumerWidget so
// provider changes only rebuild the affected section, not the entire screen.
class HomeScreen extends ConsumerWidget {
  final VoidCallback? onSeeAllArchive;
  final VoidCallback? onSeeAllEvents;
  final void Function(EventModel event)? onEventTap;

  const HomeScreen({
    super.key,
    this.onSeeAllArchive,
    this.onSeeAllEvents,
    this.onEventTap,
  });

  static const double _pageH = 16;
  static const double _sectionGap = 26;
  static const double _headerToContent = 16;
  static const double _homeCardListHeight = 300;

  static double _largeTextExtra(BuildContext context, double maxExtra) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    return ((textScale - 1.0).clamp(0.0, 1.0) * maxExtra).toDouble();
  }

  static double _homeCardListHeightFor(BuildContext context) {
    return _homeCardListHeight + _largeTextExtra(context, 58);
  }

  static String _translateCategory(String id, AppLocalizations l10n) {
    switch (id.toLowerCase()) {
      case 'food':
      case 'traditional_food':
        return l10n.cat_food;
      case 'craft':
      case 'handicraft':
        return l10n.cat_craft;
      case 'music':
        return l10n.cat_music;
      case 'dance':
        return l10n.cat_dance;
      case 'architecture':
        return l10n.cat_architecture;
      case 'clothing':
      case 'traditional_clothing':
        return l10n.cat_clothing;
      default:
        return id;
    }
  }

  static String _translateAttractionCategory(String value, bool isAr) {
  if (!isAr) return value;

  switch (value.toLowerCase()) {
    case 'heritage':
      return 'تراث';
    case 'nature':
      return 'طبيعة';
    case 'arts':
      return 'فنون';
    case 'modern':
      return 'عصري';
    default:
      return value;
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final isGuest = user == null || user.role == UserRole.guest;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RepaintBoundary(child: HomeHeroSlider()),
              const SizedBox(height: _sectionGap),

              if (!isGuest) ...[
              _YouMayLikeSection(onEventTap: onEventTap),
              const SizedBox(height: _sectionGap),
               ],
              _HeritageSection(onSeeAll: onSeeAllArchive),
              const SizedBox(height: _sectionGap),
              const _AttractionsSection(),
              const SizedBox(height: _sectionGap),
              const _TripsSection(),
              const SizedBox(height: _sectionGap),
              _EventsSection(onEventTap: onEventTap, onSeeAll: onSeeAllEvents),
              const SizedBox(height: _sectionGap),
            ],
          ),
        ),
      ),
    );
  }
}

// ── You May Like ──────────────────────────────────────────────────────────────
// PERFORMANCE OPTIMIZATION: Watches attractionsStreamProvider and a .select()
// on authNotifierProvider that only fires when interests change, not on any
// other user field update (e.g. profile picture).

class _YouMayLikeSection extends ConsumerWidget {
  final void Function(EventModel event)? onEventTap;

  const _YouMayLikeSection({this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final listHeight = HomeScreen._homeCardListHeightFor(context);

    final user = ref.watch(authNotifierProvider.select((a) => a.valueOrNull));
    if (user is TutorModel) return const SizedBox.shrink();

    final interests = user is TouristModel ? user.culturalInterests : const <String>[];

    final recommendationsAsync = ref.watch(homeRecommendationsProvider(interests));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.homeYouMayLikeTitle, onTap: null),
        const SizedBox(height: HomeScreen._headerToContent),
        recommendationsAsync.when(
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: HomeScreen._pageH),
                clipBehavior: Clip.none,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: _buildCard(context, item, isAr),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: listHeight,
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, RecommendedItem item, bool isAr) {
    final title = isAr ? item.titleAr : item.titleEn;
    final image = item.imageUrl ?? '';

    switch (item.type) {
      case RecommendedItemType.attraction:
        final a = item.source as AttractionModel;
        return ExploreHeritageHomeCard(
          title: title,
          image: image,
          categoryLabel: HomeScreen._translateAttractionCategory(a.category, isAr),
          locationLabel: a.getCity(isAr),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AttractionDetailsScreen(attraction: a)),
          ),
        );
      case RecommendedItemType.trip:
        final t = item.source as TripModel;
        return ExploreHeritageHomeCard(
          title: title,
          image: image,
          categoryLabel: t.price.replaceAll('ر.س', '').replaceAll('SAR', '').replaceAll('﷼', '').trim(),
          locationLabel: t.getCity(isAr),
          showRiyalIcon: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: t)),
          ),
        );
      case RecommendedItemType.event:
        final e = item.source as EventModel;
        return ExploreHeritageHomeCard(
          title: title,
          image: image,
          categoryLabel: isAr ? e.eventType.labelAr : e.eventType.labelEn,
          locationLabel: e.getRegion(isAr),
          onTap: () => onEventTap?.call(e),
        );
      case RecommendedItemType.culturalItem:
        final c = item.source as CulturalItemModel;
        return ExploreHeritageHomeCard(
          title: title,
          image: image,
          categoryLabel: HomeScreen._translateCategory(c.categoryId, AppLocalizations.of(context)),
          locationLabel: isAr ? c.regionAr : c.regionEn,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CulturalItemDetails(item: c)),
          ),
        );
    }
  }
}

// ── Explore Saudi Heritage ────────────────────────────────────────────────────
// PERFORMANCE OPTIMIZATION: Only rebuilds when culturalNotifierProvider changes.

class _HeritageSection extends ConsumerWidget {
  final VoidCallback? onSeeAll;
  const _HeritageSection({this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final listHeight = HomeScreen._homeCardListHeightFor(context);
    final culturalAsync = ref.watch(culturalNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.homeExploreHeritageTitle,
          onTap: onSeeAll ??
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CulturalArchive()),
                  ),
        ),
        const SizedBox(height: HomeScreen._headerToContent),
        culturalAsync.when(
          data: (state) {
            final items = state.allItems.take(4).toList();
            if (items.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeScreen._pageH),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ExploreHeritageHomeCard(
                      title: isAr ? item.titleAr : item.titleEn,
                      image: item.imageUrl,
                      categoryLabel: HomeScreen._translateCategory(
                          item.categoryId, l10n),
                      locationLabel:
                          isAr ? item.regionAr : item.regionEn,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CulturalItemDetails(item: item),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: listHeight,
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, __) => SizedBox(
            height: listHeight,
            child: Center(child: Icon(Icons.error_outline)),
          ),
        ),
      ],
    );
  }
}

// ── Attractions ───────────────────────────────────────────────────────────────
// PERFORMANCE OPTIMIZATION: Only rebuilds when attractionsStreamProvider changes.
// Shares the cached stream value with _YouMayLikeSection — no duplicate Firestore read.

class _AttractionsSection extends ConsumerWidget {
  const _AttractionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final listHeight = HomeScreen._homeCardListHeightFor(context);
    final attractionsAsync = ref.watch(attractionsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.homeAttractionsSectionTitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AttractionsListScreen()),
          ),
        ),
        const SizedBox(height: HomeScreen._headerToContent),
        attractionsAsync.when(
          data: (items) {
            final shown = items.take(4).toList();
            if (shown.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeScreen._pageH),
                itemCount: shown.length,
                itemBuilder: (context, index) {
                  final a = shown[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ExploreHeritageHomeCard(
                      title: a.getName(isAr),
                      image: a.mainImage,
                      categoryLabel:
                     HomeScreen._translateAttractionCategory(a.category, isAr),
                      locationLabel: a.getCity(isAr),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AttractionDetailsScreen(attraction: a),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: listHeight,
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Trips ─────────────────────────────────────────────────────────────────────
// PERFORMANCE OPTIMIZATION: Only rebuilds when allTripsStreamProvider changes.

class _TripsSection extends ConsumerWidget {
  const _TripsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final listHeight = HomeScreen._homeCardListHeightFor(context);
    final tripsAsync = ref.watch(allTripsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.homeTripsSectionTitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TripsListScreen()),
          ),
        ),
        const SizedBox(height: HomeScreen._headerToContent),
        tripsAsync.when(
          data: (trips) {
            final shown = trips.take(4).toList();
            if (shown.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeScreen._pageH),
                itemCount: shown.length,
                itemBuilder: (context, index) {
                  final trip = shown[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ExploreHeritageHomeCard(
                      title: trip.getTitle(isAr),
                      image: trip.imageUrl,
                      categoryLabel: trip.price,
                      locationLabel: trip.getCity(isAr),
                      showRiyalIcon: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripDetailsScreen(trip: trip),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: listHeight,
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Events ────────────────────────────────────────────────────────────────────
// PERFORMANCE OPTIMIZATION: Only rebuilds when upcomingEventsStreamProvider changes.

class _EventsSection extends ConsumerWidget {
  final void Function(EventModel event)? onEventTap;
  final VoidCallback? onSeeAll;
  const _EventsSection({this.onEventTap, this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final listHeight = HomeScreen._homeCardListHeightFor(context);
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.homeEventsSectionTitle,
          onTap: onSeeAll,
        ),
        const SizedBox(height: HomeScreen._headerToContent),
        eventsAsync.when(
          data: (events) {
            final shown = events.take(4).toList();
            if (shown.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeScreen._pageH),
                itemCount: shown.length,
                itemBuilder: (context, index) {
                  final event = shown[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ExploreHeritageHomeCard(
                      title: event.getTitle(isAr),
                      image: event.imageUrl,
                      categoryLabel: isAr
                          ? event.eventType.labelAr
                          : event.eventType.labelEn,
                      locationLabel: event.getRegion(isAr),
                      onTap: () => onEventTap?.call(event),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: listHeight,
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SectionHeader({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeScreen._pageH),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (onTap != null)
            const SizedBox(width: 10),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.25,
                      ),
                      child: Text(
                        l10n.seeAllLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(
  color: theme.colorScheme.primary,
  fontWeight: FontWeight.w700,
  fontSize: 13,
),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right,
                        size: 16, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
