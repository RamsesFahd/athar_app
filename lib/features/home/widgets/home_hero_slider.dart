import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/services/gemini_service.dart';

class HomeHeroSlider extends ConsumerStatefulWidget {
  const HomeHeroSlider({super.key});

  @override
  ConsumerState<HomeHeroSlider> createState() => _HomeHeroSliderState();
}

class _HomeHeroSliderState extends ConsumerState<HomeHeroSlider> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _currentIndex = 0;
  int _lastLength = 0;

  String? _lastSignature;
  Map<int, _AiHeroText> _aiTexts = {};

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer(int length) {
    if (_lastLength == length && _timer != null) return;
    _lastLength = length;

    _timer?.cancel();
    if (length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_controller.hasClients) return;
      final nextPage = (_currentIndex + 1) % length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _generateAiTexts(List<_HeroSlideData> slides) async {
    final signature = slides.map((s) => '${s.kind}-${s.titleEn}').join('|');
    if (_lastSignature == signature) return;
    _lastSignature = signature;

    try {
      final gemini = ref.read(geminiServiceProvider);

      final items = slides.asMap().entries.map((entry) {
        final s = entry.value;
        return {
          'index': entry.key,
          'type': s.kind.name,
          'titleAr': s.titleAr,
          'titleEn': s.titleEn,
          'subtitleAr': s.subtitleAr,
          'subtitleEn': s.subtitleEn,
        };
      }).toList();

      final response = await gemini.getResponse(
        systemInstruction:
            'You are Rawi, Athar app cultural storytelling assistant. Write premium cinematic promotional hero banner copy for a Saudi cultural heritage app. Return ONLY valid JSON. No markdown.',
        prompt: '''
Generate bilingual hero slider copy for these items.

Rules:
- Return JSON array only.
- Each item must include: index, titleAr, subtitleAr, titleEn, subtitleEn.
- Arabic should feel elegant, emotional, Saudi-friendly, and promotional.
- English should be short, polished, and premium.
- Do NOT mention AI.
- Do NOT use generic phrases.
- Title max 7 words.
- Subtitle max 12 words.

Items:
${jsonEncode(items)}
''',
      );

      final cleaned =
          response.replaceAll('```json', '').replaceAll('```', '').trim();

      final parsed = jsonDecode(cleaned);
      if (parsed is! List) return;

      final result = <int, _AiHeroText>{};

      for (final item in parsed) {
        if (item is Map<String, dynamic>) {
          final index = item['index'];
          if (index is int) {
            result[index] = _AiHeroText(
              titleAr: item['titleAr']?.toString() ?? '',
              subtitleAr: item['subtitleAr']?.toString() ?? '',
              titleEn: item['titleEn']?.toString() ?? '',
              subtitleEn: item['subtitleEn']?.toString() ?? '',
            );
          }
        }
      }

      if (!mounted) return;
      setState(() => _aiTexts = result);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isHighContrast = theme.colorScheme.primary == Colors.black;
    
    final userAsync = ref.watch(authNotifierProvider);
    final attractionsAsync = ref.watch(attractionsStreamProvider);
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);
    final culturalAsync = ref.watch(culturalNotifierProvider);
    final tripsAsync = ref.watch(allTripsStreamProvider);

    final tourist = userAsync.valueOrNull is TouristModel
        ? userAsync.valueOrNull as TouristModel
        : null;

    final interests = tourist?.interests ?? <String>[];
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

    if (slides.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateAiTexts(slides);
        _startTimer(slides.length);
      });
    }

    if (slides.isEmpty) return _StaticHeroFallback(isAr: isAr);

    return SizedBox(
      height: 430,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final slide = slides[index];
              final ai = _aiTexts[index];

              final title = isAr
                  ? (ai?.titleAr.isNotEmpty == true
                      ? ai!.titleAr
                      : slide.titleAr)
                  : (ai?.titleEn.isNotEmpty == true
                      ? ai!.titleEn
                      : slide.titleEn);

              final subtitle = isAr
                  ? (ai?.subtitleAr.isNotEmpty == true
                      ? ai!.subtitleAr
                      : slide.subtitleAr)
                  : (ai?.subtitleEn.isNotEmpty == true
                      ? ai!.subtitleEn
                      : slide.subtitleEn);

              return _CinematicHeroSlide(
                slide: slide,
                title: title,
                subtitle: subtitle,
                isAr: isAr,
                isActive: index == _currentIndex,
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
                final active = index == _currentIndex;
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

  List<_HeroSlideData> _buildSlides({
    required BuildContext context,
    required List<AttractionModel> attractions,
    required List<EventModel> events,
    required List<CulturalItemModel> culturalItems,
    required List<TripModel> trips,
    required List<String> interests,
  }) {
    final slides = <_HeroSlideData>[];

    if (events.isNotEmpty) {
      final event = events.first;
      slides.add(
        _HeroSlideData(
          kind: _HeroKind.event,
          imageUrl: event.imageUrl,
          badgeAr: 'العد التنازلي بدأ',
          badgeEn: 'The Countdown Begins',
          titleAr: event.titleAr,
          titleEn: event.titleEn,
          subtitleAr: 'فعالية ثقافية تقترب من لحظتها',
          subtitleEn: 'A cultural moment is almost here',
          countdownDate: event.eventDate,
          ctaAr: 'استعد للتجربة',
          ctaEn: 'Get Ready',
          onTap: null,
        ),
      );
    }


    if (attractions.isNotEmpty) {

  final mirrorAttraction = attractions.firstWhere(
    (a) {
      final text =
          '${a.getName(true)} ${a.getName(false)}'.toLowerCase();

      return text.contains('مرايا') ||
          text.contains('maraya');
    },
    orElse: () => attractions.first,
  );

  slides.add(
    _HeroSlideData(
      kind: _HeroKind.attraction,
      imageUrl: mirrorAttraction.mainImage,
      badgeAr: '',
      badgeEn: '',
      titleAr: 'مرايا العلا',
      titleEn: 'Maraya AlUla',
      subtitleAr: 'تحفة معمارية تعكس جمال الصحراء',
      subtitleEn: 'A mirrored landmark reflecting the desert',
      ctaAr: 'استكشف المعلم',
      ctaEn: 'Explore Landmark',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttractionDetailsScreen(
              attraction: mirrorAttraction,
            ),
          ),
        );
      },
    ),
  );
}

    final contributionItems =
        culturalItems.where((item) => item.isContribution).toList();

    if (contributionItems.isNotEmpty) {
      final contributionItems =
    culturalItems.where((item) => item.isContribution).toList();

if (contributionItems.isNotEmpty) {

  final item = contributionItems.first;

  slides.add(
    _HeroSlideData(
      kind: _HeroKind.community,
      imageUrl: item.imageUrl,
      badgeAr: '',
      badgeEn: '',
      titleAr: 'شارك الأثر من منظورك',
      titleEn: 'Share Athar Through Your Lens',
      subtitleAr:
          'وثّق الأماكن والقصص التي تستحق أن تُروى',
      subtitleEn:
          'Capture places and stories worth preserving',
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
    
   if (culturalItems.isNotEmpty) {

  final item = culturalItems.firstWhere(
    (item) {
      final text =
          '${item.titleAr} ${item.titleEn}'.toLowerCase();

      return text.contains('المرفوع') ||
    text.contains('marfoo');
    },
    orElse: () => culturalItems.first,
  );

  slides.add(
    _HeroSlideData(
      kind: _HeroKind.archive,
      imageUrl: item.imageUrl,
      badgeAr: '',
      badgeEn: '',
      titleAr: 'ثقافة تُلبس وتُروى',
      titleEn: 'Culture Woven Into Every Detail',
      subtitleAr:
          'اكتشف الأزياء والعادات التي تميز مناطق المملكة',
      subtitleEn:
          'Discover traditions and clothing across the Kingdom',
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
}

    if (trips.isNotEmpty) {
      final balloonTrip = trips.where((trip) {
        final text =
            '${trip.titleAr} ${trip.titleEn} ${trip.descriptionAr} ${trip.descriptionEn}'
                .toLowerCase();
        return text.contains('منطاد') || text.contains('balloon');
      }).toList();

      final trip = balloonTrip.isNotEmpty ? balloonTrip.first : trips.first;

      slides.add(
        _HeroSlideData(
          kind: _HeroKind.trip,
          imageUrl: trip.imageUrl,
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
  final String? imageUrlEn;
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
    this.imageUrlEn,
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

class _AiHeroText {
  final String titleAr;
  final String subtitleAr;
  final String titleEn;
  final String subtitleEn;

  const _AiHeroText({
    required this.titleAr,
    required this.subtitleAr,
    required this.titleEn,
    required this.subtitleEn,
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

    return GestureDetector(
      onTap: slide.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 1.0,
              end: isActive ? 1.08 : 1.0,
            ),
            duration: const Duration(seconds: 6),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: _HeroImage(
            imageUrl: !isAr && slide.imageUrlEn != null
            ? slide.imageUrlEn!
            : slide.imageUrl,
),
          ),
         _HeroGradient(
          kind: slide.kind,
          isHighContrast: theme.colorScheme.primary == Colors.black,
           ),
          PositionedDirectional(
            start: 24,
            end: 24,
            bottom: 58,
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

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (slide.kind == _HeroKind.event &&
          slide.countdownDate != null) ...[
        _LargeCountdown(
          date: slide.countdownDate!,
          isAr: isAr,
        ),
        const SizedBox(height: 18),
      ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: 34,
            height: 1.06,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 14),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.94),
            fontWeight: FontWeight.w600,
            height: 1.45,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 10),
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

  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset('assets/images/archive_en.jpeg', fit: BoxFit.cover);
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset('assets/images/archive_en.jpeg', fit: BoxFit.cover);
      },
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

class _PremiumBadge extends StatelessWidget {
  final String text;

  const _PremiumBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountdownUnit(value: '$days', label: isAr ? 'يوم' : 'Days'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
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
    final isHighContrast = theme.colorScheme.primary == Colors.black;

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
       style: TextStyle(
       color: isHighContrast ? Colors.black : const Color(0xFF344235),
       fontWeight: FontWeight.w900,
       fontSize: 12,
       ),
      ),
    );
  }
}

class _StaticHeroFallback extends StatelessWidget {
  final bool isAr;

  const _StaticHeroFallback({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            isAr
                ? 'assets/images/archive_ar.jpeg'
                : 'assets/images/archive_en.jpeg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.55)),
          PositionedDirectional(
            start: 24,
            end: 24,
            bottom: 58,
            child: Text(
              isAr ? 'اكتشف تراث المملكة' : 'Discover Saudi Heritage',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}