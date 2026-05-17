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
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/attractions/screens/attractions_list_screen.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/screens/trips_list_screen.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/features/events/logic/events_repository.dart';
import 'package:athar_app/core/models/events/event_model.dart';

// PERFORMANCE OPTIMIZATION: HomeScreen converted from ConsumerWidget to
// StatelessWidget. Each carousel section is now its own ConsumerWidget so
// provider changes only rebuild the affected section, not the entire screen.
class HomeScreen extends StatelessWidget {
  final VoidCallback? onSeeAllArchive;
  final void Function(EventModel event)? onEventTap;

  const HomeScreen({
    super.key,
    this.onSeeAllArchive,
    this.onEventTap,
  });

  static const double _pageH = 16;
  static const double _sectionGap = 26;
  static const double _headerToContent = 16;
  static const double _homeCardListHeight = 285;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeroSlider(),
              const SizedBox(height: _sectionGap),
              const _YouMayLikeSection(),
              const SizedBox(height: _sectionGap),
              _HeritageSection(onSeeAll: onSeeAllArchive),
              const SizedBox(height: _sectionGap),
              const _AttractionsSection(),
              const SizedBox(height: _sectionGap),
              const _TripsSection(),
              const SizedBox(height: _sectionGap),
              _EventsSection(onEventTap: onEventTap),
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
  const _YouMayLikeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final interests = ref.watch(
      authNotifierProvider.select((async) {
        final user = async.valueOrNull;
        return user is TouristModel
            ? (user.culturalInterests ?? const <String>[])
            : const <String>[];
      }),
    );

    final attractionsAsync = ref.watch(attractionsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.homeYouMayLikeTitle, onTap: null),
        const SizedBox(height: HomeScreen._headerToContent),
        attractionsAsync.when(
          data: (all) {
            final recommended = interests.isNotEmpty
                ? all
                    .where(
                        (a) => a.tags.any((t) => interests.contains(t)))
                    .take(4)
                    .toList()
                : <AttractionModel>[];
            final items =
                recommended.isNotEmpty ? recommended : all.take(4).toList();

            if (items.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: HomeScreen._homeCardListHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeScreen._pageH),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final a = items[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ExploreHeritageHomeCard(
                      title: a.getName(isAr),
                      image: a.mainImage,
                      categoryLabel: a.category,
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
          loading: () => const SizedBox(
            height: HomeScreen._homeCardListHeight,
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
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
              height: HomeScreen._homeCardListHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
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
          loading: () => const SizedBox(
            height: HomeScreen._homeCardListHeight,
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, __) => const SizedBox(
            height: 245,
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
    final attractionsAsync = ref.watch(attractionsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'المعالم السياحية' : 'Attractions',
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
              height: HomeScreen._homeCardListHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
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
                      categoryLabel: a.category,
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
          loading: () => const SizedBox(
            height: HomeScreen._homeCardListHeight,
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
    final tripsAsync = ref.watch(allTripsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'الرحلات' : 'Trips',
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
              height: HomeScreen._homeCardListHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
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
          loading: () => const SizedBox(
            height: HomeScreen._homeCardListHeight,
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
  const _EventsSection({this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'الفعاليات' : 'Events',
          onTap: null,
        ),
        const SizedBox(height: HomeScreen._headerToContent),
        eventsAsync.when(
          data: (events) {
            final shown = events.take(4).toList();
            if (shown.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: HomeScreen._homeCardListHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
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
          loading: () => const SizedBox(
            height: HomeScreen._homeCardListHeight,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.seeAllLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right,
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
