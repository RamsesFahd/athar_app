import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/theme/app_theme.dart';

import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/features/events/logic/events_repository.dart';
import 'package:athar_app/features/events/screens/event_details_screen.dart';
import 'package:athar_app/features/guide_market/logic/trips_repository.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/features/home/models/hero_ai_text.dart';

class HomeHeroSlider extends ConsumerStatefulWidget {
  const HomeHeroSlider({super.key});

  @override
  ConsumerState<HomeHeroSlider> createState() => _HomeHeroSliderState();
}

class _HomeHeroSliderState extends ConsumerState<HomeHeroSlider> {
  // Virtual multiplier: PageView thinks it has slides.length × _kVirtual pages.
  // The timer always advances +1 so we never animate backwards to "page 0".
  static const int _kVirtual = 10000;

  late final PageController _controller;
  Timer? _timer;
  int _virtualPage = 0; // position inside the virtual list
  int _lastLength = 0;
  late final int _rotationSeed;

  // Shown as active dot indicator and passed as isActive to each slide.
  int get _logicalIndex => _lastLength == 0 ? 0 : _virtualPage % _lastLength;

  // Tracks whether we've already kicked off a background precache for slide[0].
  bool _precachingTriggered = false;

  T _pickByRotation<T>(List<T> items, int offset) {
    final index = (_rotationSeed + offset) % items.length;
    return items[index];
  }

  @override
  void initState() {
    super.initState();
    _rotationSeed =
        DateTime.now().millisecondsSinceEpoch ~/
        Duration.millisecondsPerHour;
    _controller = PageController();
  }

  // Fire-and-forget background warmup for slide[0].
  // Does NOT gate display — the slider is already visible when this runs.
  // Benefit: if the user hasn't scrolled yet, slide[0] re-renders from memory
  // instead of re-downloading when CachedNetworkImage's in-memory entry expires.
  Future<void> _warmupFirstSlide(String imageUrl) async {
    if (!mounted || imageUrl.isEmpty || imageUrl.startsWith('assets/')) return;
    try {
      await precacheImage(NetworkImage(imageUrl), context);
    } catch (_) {
      // Ignore — CachedNetworkImage handles loading and retries independently.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer(int length) {
    if (_lastLength == length && _timer != null) return;

    // First time data arrives: jump PageController to the virtual middle
    // so the user can swipe both directions indefinitely without hitting an edge.
    if (_lastLength == 0 && length > 0) {
      final midPage = length * (_kVirtual ~/ 2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(midPage);
          setState(() => _virtualPage = midPage);
        }
      });
    }

    _lastLength = length;
    _timer?.cancel();
    if (length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_controller.hasClients) return;
      // Always go +1 forward in the virtual list — never animates backwards.
      _controller.animateToPage(
        _controller.page!.round() + 1,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;
    final heroHeight = 430 + _largeTextExtra(context, 78);

    final userAsync = ref.watch(authNotifierProvider);
    final attractionsAsync = ref.watch(attractionsStreamProvider);
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);
    final culturalAsync = ref.watch(culturalNotifierProvider);
    final tripsAsync = ref.watch(allTripsStreamProvider);

    final tourist = userAsync.valueOrNull is TouristModel
        ? userAsync.valueOrNull as TouristModel
        : null;

    final interests = tourist?.culturalInterests ?? <String>[];
    final attractions =
        attractionsAsync.valueOrNull ?? const <AttractionModel>[];
    final events = eventsAsync.valueOrNull ?? const <EventModel>[];
    final culturalItems =
        culturalAsync.valueOrNull?.allItems ?? const <CulturalItemModel>[];
    final trips = tripsAsync.valueOrNull ?? const <TripModel>[];

    final slides = _buildSlides(
      context: context,
      attractions: attractions,
      events: events,
      culturalItems: culturalItems,
      trips: trips,
      interests: interests,
    );

    // Show skeleton only when all providers have no data yet (first cold launch
    // or offline with empty cache). Any data — cache or server — is good enough.
    if (slides.isEmpty) return const _SkeletonHeroFallback();

    // Background warmup for slide[0]: kicked off once, does not block display.
    if (!_precachingTriggered) {
      _precachingTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _warmupFirstSlide(slides.first.imageUrl),
      );
    }

    // Schedule the auto-advance timer only when the slide count changes,
    // not on every build. _startTimer itself early-returns if unchanged,
    // but this avoids queuing a post-frame callback on each rebuild.
    if (_lastLength != slides.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer(slides.length);
      });
    }

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            // Virtual item count: timer always advances +1, never wraps to 0.
            itemCount: slides.length * _kVirtual,
            onPageChanged: (index) => setState(() => _virtualPage = index),
            itemBuilder: (context, index) {
              final slide = slides[index % slides.length];
              final heroCopy = slide.heroCopy;

              final title = isAr
                  ? (heroCopy?.titleAr.isNotEmpty == true
                      ? heroCopy!.titleAr
                      : slide.titleAr)
                  : (heroCopy?.titleEn.isNotEmpty == true
                      ? heroCopy!.titleEn
                      : slide.titleEn);

              final subtitle = isAr
                  ? (heroCopy?.subtitleAr.isNotEmpty == true
                      ? heroCopy!.subtitleAr
                      : slide.subtitleAr)
                  : (heroCopy?.subtitleEn.isNotEmpty == true
                      ? heroCopy!.subtitleEn
                      : slide.subtitleEn);

              return _CinematicHeroSlide(
                slide: slide,
                title: title,
                subtitle: subtitle,
                isAr: isAr,
                isActive: (index % slides.length) == _logicalIndex,
              );
            },
          ),
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (index) {
                final active = index == _logicalIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isHighContrast
                        ? Colors.white
                        : Colors.white.withValues(alpha: active ? 0.95 : 0.42),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Picks up to [n] items from [items] using a seeded Random for reproducible
  // hourly rotation shared across all users with the same seed.
  List<T> _pickN<T>(List<T> items, int n, Random rng) {
    if (items.isEmpty || n <= 0) return [];
    final copy = List<T>.from(items)..shuffle(rng);
    return copy.take(n).toList();
  }

  List<_HeroSlideData> _buildSlides({
    required BuildContext context,
    required List<AttractionModel> attractions,
    required List<EventModel> events,
    required List<CulturalItemModel> culturalItems,
    required List<TripModel> trips,
    required List<String> interests,
  }) {
    // ── Branch 1: tourist with interests ──────────────────────────────────────
    // Filter each collection to items matching at least one of the user's
    // interests, then pick with a seeded Random so all tourists with the same
    // interests see identical slides within the same hour.
    if (interests.isNotEmpty) {
      final rng = Random(_rotationSeed);

      final filteredCultural = culturalItems
          .where((c) => c.interestIds.any(interests.contains))
          .toList();
      final filteredTrips = trips
          .where((t) => t.interestIds.any(interests.contains))
          .toList();
      final filteredEvents = events
          .where((e) => e.interestIds.any(interests.contains))
          .toList();
      final filteredAttractions = attractions
          .where((a) => a.interestIds.any(interests.contains))
          .toList();

      // Fixed pick order so the seed always resolves to the same 5 items.
      final pickedCultural     = _pickN(filteredCultural, 1, rng);
      final pickedTrips        = _pickN(filteredTrips, 2, rng);
      final pickedEvents       = _pickN(filteredEvents, 1, rng);
      final pickedAttractions  = _pickN(filteredAttractions, 1, rng);

      final slides = <_HeroSlideData>[];

      for (final item in pickedCultural) {
        slides.add(_HeroSlideData(
          kind: item.isContribution ? _HeroKind.community : _HeroKind.archive,
          imageUrl: item.imageUrl,
          heroCopy: item.heroCopy,
          badgeAr: '',
          badgeEn: '',
          titleAr: item.titleAr,
          titleEn: item.titleEn,
          subtitleAr: item.descriptionAr,
          subtitleEn: item.descriptionEn,
          ctaAr: item.isContribution ? 'شارك الأثر' : 'افتح الأرشيف',
          ctaEn: item.isContribution ? 'Share Athar' : 'Open Archive',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CulturalItemDetails(item: item)),
          ),
        ));
      }

      for (final trip in pickedTrips) {
        slides.add(_HeroSlideData(
          kind: _HeroKind.trip,
          imageUrl: trip.imageUrl,
          heroCopy: trip.heroCopy,
          badgeAr: 'رحلة المنطاد',
          badgeEn: 'Balloon Experience',
          titleAr: trip.getTitle(true),
          titleEn: trip.getTitle(false),
          subtitleAr: 'حلّق فوق التفاصيل التي لا تُنسى',
          subtitleEn: 'Rise above a landscape made for memory',
          ctaAr: 'احجز التجربة',
          ctaEn: 'Book Experience',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: trip)),
          ),
        ));
      }

      for (final event in pickedEvents) {
        slides.add(_HeroSlideData(
          kind: _HeroKind.event,
          imageUrl: event.imageUrl,
          heroCopy: event.heroCopy,
          badgeAr: 'العد التنازلي بدأ',
          badgeEn: 'The Countdown Begins',
          titleAr: event.titleAr,
          titleEn: event.titleEn,
          subtitleAr: 'فعالية ثقافية تقترب من لحظتها',
          subtitleEn: 'A cultural moment is almost here',
          countdownDate: event.eventDate,
          ctaAr: 'اكتشف المزيد',
          ctaEn: 'Discover More',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
          ),
        ));
      }

      for (final attraction in pickedAttractions) {
        slides.add(_HeroSlideData(
          kind: _HeroKind.attraction,
          imageUrl: attraction.mainImage,
          heroCopy: attraction.heroCopy,
          badgeAr: '',
          badgeEn: '',
          titleAr: attraction.getName(true),
          titleEn: attraction.getName(false),
          subtitleAr: attraction.getDescription(true),
          subtitleEn: attraction.getDescription(false),
          ctaAr: 'استكشف المعلم',
          ctaEn: 'Explore Landmark',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttractionDetailsScreen(attraction: attraction),
            ),
          ),
        ));
      }

      return slides.take(5).toList();
    }

    // ── Branch 2: guide, visitor, or tourist with no interests ─────────────
    // Existing hourly-rotation behaviour — unchanged.
    final slides = <_HeroSlideData>[];

    if (events.isNotEmpty) {
      final event = events.first;
      slides.add(
        _HeroSlideData(
          kind: _HeroKind.event,
          imageUrl: event.imageUrl,
          heroCopy: event.heroCopy,
          badgeAr: 'العد التنازلي بدأ',
          badgeEn: 'The Countdown Begins',
          titleAr: event.titleAr,
          titleEn: event.titleEn,
          subtitleAr: 'فعالية ثقافية تقترب من لحظتها',
          subtitleEn: 'A cultural moment is almost here',
          countdownDate: event.eventDate,
          ctaAr: 'اكتشف المزيد',
          ctaEn: 'Discover More',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(event: event),
            ),
          ),
        ),
      );
    }

    if (attractions.isNotEmpty) {
      final attraction = _pickByRotation(attractions, 1);
      slides.add(
        _HeroSlideData(
          kind: _HeroKind.attraction,
          imageUrl: attraction.mainImage,
          heroCopy: attraction.heroCopy,
          badgeAr: '',
          badgeEn: '',
          titleAr: attraction.getName(true),
          titleEn: attraction.getName(false),
          subtitleAr: attraction.getDescription(true),
          subtitleEn: attraction.getDescription(false),
          ctaAr: 'استكشف المعلم',
          ctaEn: 'Explore Landmark',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AttractionDetailsScreen(attraction: attraction),
              ),
            );
          },
        ),
      );
    }

    final contributionItems =
        culturalItems.where((item) => item.isContribution).toList();

    if (contributionItems.isNotEmpty) {
      final item = _pickByRotation(contributionItems, 2);
      slides.add(
        _HeroSlideData(
          kind: _HeroKind.community,
          imageUrl: item.imageUrl,
          heroCopy: item.heroCopy,
          badgeAr: '',
          badgeEn: '',
          titleAr: item.titleAr,
          titleEn: item.titleEn,
          subtitleAr: item.descriptionAr,
          subtitleEn: item.descriptionEn,
          ctaAr: 'شارك الأثر',
          ctaEn: 'Share Athar',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CulturalItemDetails(item: item),
              ),
            );
          },
        ),
      );
    }

    final archiveItems =
        culturalItems.where((item) => !item.isContribution).toList();

    if (archiveItems.isNotEmpty) {
      final item = _pickByRotation(archiveItems, 3);
      slides.add(
        _HeroSlideData(
          kind: _HeroKind.archive,
          imageUrl: item.imageUrl,
          heroCopy: item.heroCopy,
          badgeAr: '',
          badgeEn: '',
          titleAr: item.titleAr,
          titleEn: item.titleEn,
          subtitleAr: item.descriptionAr,
          subtitleEn: item.descriptionEn,
          ctaAr: 'افتح الأرشيف',
          ctaEn: 'Open Archive',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CulturalItemDetails(item: item),
              ),
            );
          },
        ),
      );
    }

    if (trips.isNotEmpty) {
      final trip = _pickByRotation(trips, 4);
      slides.add(
        _HeroSlideData(
          kind: _HeroKind.trip,
          imageUrl: trip.imageUrl,
          heroCopy: trip.heroCopy,
          badgeAr: 'رحلة المنطاد',
          badgeEn: 'Balloon Experience',
          titleAr: trip.getTitle(true),
          titleEn: trip.getTitle(false),
          subtitleAr: 'حلّق فوق التفاصيل التي لا تُنسى',
          subtitleEn: 'Rise above a landscape made for memory',
          ctaAr: 'احجز التجربة',
          ctaEn: 'Book Experience',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripDetailsScreen(trip: trip),
              ),
            );
          },
        ),
      );
    }

    return slides.take(5).toList();
  }
}

enum _HeroKind {
  event,
  attraction,
  community,
  archive,
  trip,
}

class _HeroSlideData {
  final _HeroKind kind;
  final String imageUrl;
  final HeroAiText? heroCopy;
  final String badgeAr;
  final String badgeEn;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final DateTime? countdownDate;
  final String ctaAr;
  final String ctaEn;
  final VoidCallback? onTap;

  const _HeroSlideData({
    required this.kind,
    required this.imageUrl,
    this.heroCopy,
    required this.badgeAr,
    required this.badgeEn,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.ctaAr,
    required this.ctaEn,
    this.countdownDate,
    this.onTap,
  });
}


class _CinematicHeroSlide extends StatelessWidget {
  final _HeroSlideData slide;
  final String title;
  final String subtitle;
  final bool isAr;
  final bool isActive;

  const _CinematicHeroSlide({
    required this.slide,
    required this.title,
    required this.subtitle,
    required this.isAr,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cta = isAr ? slide.ctaAr : slide.ctaEn;
    final bottomInset = 58 + _largeTextExtra(context, 16);

    return GestureDetector(
      onTap: slide.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: _HeroImage(
              key: ValueKey(slide.imageUrl),
              imageUrl: slide.imageUrl,
            ),
          ),
          _HeroGradient(
            kind: slide.kind,
            isHighContrast: theme.isHighContrast,
          ),
          PositionedDirectional(
            start: 24,
            end: 24,
            bottom: bottomInset,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: _AdContent(
                key: ValueKey(title),
                slide: slide,
                title: title,
                subtitle: subtitle,
                cta: cta,
                isAr: isAr,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdContent extends StatelessWidget {
  final _HeroSlideData slide;
  final String title;
  final String subtitle;
  final String cta;
  final bool isAr;
  final ThemeData theme;

  const _AdContent({
    super.key,
    required this.slide,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.isAr,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1.0) > 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (slide.kind == _HeroKind.event && slide.countdownDate != null) ...[
          _LargeCountdown(
            date: slide.countdownDate!,
            isAr: isAr,
          ),
          const SizedBox(height: 18),
        ],
        Text(
          title,
          maxLines: largeText ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: 34,
            height: 1.06,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          maxLines: largeText ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.94),
            fontWeight: FontWeight.w600,
            height: 1.45,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 3),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _HeroCta(text: cta),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String imageUrl;

  const _HeroImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset('assets/images/archive_en.jpeg', fit: BoxFit.cover);
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }

    // CachedNetworkImage: disk-caches images so subsequent slides load
    // instantly. The dark placeholder fills the frame while loading so
    // text is never visible without a background behind it.
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (_, __) => const ColoredBox(color: Color(0xFF1A1A1A)),
      errorWidget: (_, __, ___) =>
          Image.asset('assets/images/archive_en.jpeg', fit: BoxFit.cover),
    );
  }
}

class _HeroGradient extends StatelessWidget {
  final _HeroKind kind;
  final bool isHighContrast;

  const _HeroGradient({
    required this.kind,
    required this.isHighContrast,
  });

  @override
  Widget build(BuildContext context) {
    final warm = kind == _HeroKind.community || kind == _HeroKind.archive;
    final event = kind == _HeroKind.event;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isHighContrast
              ? [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.95),
                ]
              : [
                  Colors.black.withValues(alpha: event ? 0.12 : 0.04),
                  warm
                      ? const Color(0xFF3A2414).withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.92),
                ],
          stops: const [0.0, 0.50, 1.0],
        ),
      ),
    );
  }
}

class _LargeCountdown extends StatelessWidget {
  final DateTime date;
  final bool isAr;

  const _LargeCountdown({
    required this.date,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final diff = date.difference(DateTime.now());
    final days = diff.inDays.clamp(0, 999);
    final hours = diff.inHours.remainder(24).clamp(0, 23);

    return Wrap(
      spacing: 18,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _CountdownUnit(value: '$days', label: isAr ? 'يوم' : 'Days'),
        Container(
          height: 42,
          width: 1,
          color: Colors.white.withValues(alpha: 0.38),
        ),
        _CountdownUnit(value: '$hours', label: isAr ? 'ساعة' : 'Hours'),
      ],
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;

  const _CountdownUnit({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            height: 1,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: Colors.black87, blurRadius: 12),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroCta extends StatelessWidget {
  final String text;

  const _HeroCta({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isHighContrast
            ? Colors.white
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        boxShadow: isHighContrast
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color:
              isHighContrast ? theme.colorScheme.onSurface : const Color(0xFF344235),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Shown while waiting for server data + first image precache.
// Matches the hero's exact dimensions so the layout doesn't jump.
// Pulses between two dark greys — a shimmer without an extra package.
class _SkeletonHeroFallback extends StatefulWidget {
  const _SkeletonHeroFallback();

  @override
  State<_SkeletonHeroFallback> createState() => _SkeletonHeroFallbackState();
}

class _SkeletonHeroFallbackState extends State<_SkeletonHeroFallback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroHeight = 430 + _largeTextExtra(context, 78);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        height: heroHeight,
        width: double.infinity,
        child: ColoredBox(
          color: Color.lerp(
            const Color(0xFF1A1A1A),
            const Color(0xFF2C2C2C),
            _ctrl.value,
          )!,
        ),
      ),
    );
  }
}

double _largeTextExtra(BuildContext context, double maxExtra) {
  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
  return ((textScale - 1.0).clamp(0.0, 1.0) * maxExtra).toDouble();
}
