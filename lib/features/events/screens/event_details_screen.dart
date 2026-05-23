import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/features/events/widgets/event_card.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/services/tts_service.dart';

class EventDetailsScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  Color get _accent => EventCard.typeColor(event.eventType);

  static String _formatTime(String t) => t
      .replaceAll('صباحاً', 'ص')
      .replaceAll('صباحا', 'ص')
      .replaceAll('مساءً', 'م')
      .replaceAll('مساء', 'م');

  TextStyle _nameStyle(bool isAr, ThemeData theme) {
    final base = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.15,
    );
    return isAr
        ? GoogleFonts.ibmPlexSansArabic(textStyle: base)
        : GoogleFonts.playfairDisplay(textStyle: base);
  }

  TextStyle _sectionTitleStyle(bool isAr, ThemeData theme) {
    final base = theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800);
    return isAr
        ? GoogleFonts.ibmPlexSansArabic(textStyle: base)
        : GoogleFonts.playfairDisplay(textStyle: base);
  }

  TextStyle _bodyStyle(bool isAr, ThemeData theme) {
    final base = theme.textTheme.bodyLarge?.copyWith(height: 1.8);
    return isAr
        ? GoogleFonts.ibmPlexSansArabic(textStyle: base)
        : GoogleFonts.playfairDisplay(textStyle: base);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${event.latitude},${event.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _share(BuildContext context, AppLocalizations l10n) {
    final url =
        'https://maps.google.com/?q=${event.latitude},${event.longitude}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.commonLinkCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final accent = _accent;
    final gallery = event.gallery;

    final settings = ref.watch(settingsProvider);
    final ttsService = ref.read(ttsServiceProvider);

    final titleText = event.getTitle(isAr);
    final descriptionText = event.getDescription(isAr);

    final dateStr = DateFormat('EEEE، d MMMM yyyy', isAr ? 'ar' : 'en_US')
        .format(event.eventDate);

    return Scaffold(
      body: Stack(
        children: [
          // ── Scrollable content ───────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image carousel ───────────────────────────────
                _HeroCarousel(
                  images: [event.imageUrl, ...gallery],
                ),

                // ── Content ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Type badge ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          isAr
                              ? event.eventType.labelAr
                              : event.eventType.labelEn,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Title ───────────────────────────────────────
                      Text(
                        titleText,
                        style: _nameStyle(isAr, theme),
                      ),

                      const SizedBox(height: 20),

                      // ── Info cards (date | time) ─────────────────────
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.calendar_today_outlined,
                                title: isAr ? 'التاريخ' : 'Date',
                                value: Text(dateStr),
                                color: accent,
                                isAr: isAr,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.schedule_outlined,
                                title: isAr ? 'الوقت' : 'Time',
                                value: Text(_formatTime(event.getTime(isAr))),
                                color: accent,
                                isAr: isAr,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Description ──────────────────────────────────
                      Text(
                        l10n.mapAboutEvent,
                        style: _sectionTitleStyle(isAr, theme),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        descriptionText,
                        style: _bodyStyle(isAr, theme),
                      ),

                      // ── Location ─────────────────────────────────────
                      const SizedBox(height: 24),
                      Text(
                        l10n.locationLabel,
                        style: _sectionTitleStyle(isAr, theme),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.place_outlined, color: accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.getRegion(isAr),
                              style: _bodyStyle(isAr, theme),
                            ),
                          ),
                        ],
                      ),

                      // ── Ticket link ───────────────────────────────────
                      if (event.ticketUrl != null &&
                          event.ticketUrl!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => _openUrl(event.ticketUrl!),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                color: accent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.attractionTicketLink,
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top navigation overlay ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleNavButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        if (settings.isTtsEnabled)
                          _CircleNavButton(
                            icon: Icons.volume_up_rounded,
                            onTap: () {
                              ttsService.speak('$titleText. $descriptionText');
                            },
                          ),
                        if (settings.isTtsEnabled) const SizedBox(width: 8),
                        _CircleNavButton(
                          icon: Icons.share_outlined,
                          onTap: () => _share(context, l10n),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom action bar ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: ElevatedButton.icon(
                    onPressed: _openDirections,
                    icon: const Icon(Icons.directions_outlined),
                    label: Text(
                      l10n.attractionGetDirections,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CircleNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black54,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget value;
  final Color color;
  final bool isAr;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: (isAr
                          ? GoogleFonts.ibmPlexSansArabic()
                          : GoogleFonts.playfairDisplay())
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DefaultTextStyle(
            style: (isAr
                    ? GoogleFonts.ibmPlexSansArabic()
                    : GoogleFonts.playfairDisplay())
                .copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
            child: value,
          ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  final List<String> images;

  const _HeroCarousel({required this.images});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  int _currentPage = 0;
  late final PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
    if (widget.images.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var i = 1; i < widget.images.length; i++) {
          precacheImage(CachedNetworkImageProvider(widget.images[i]), context);
        }
      });
    }
  }

  void _startTimer() {
    if (widget.images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _resetTimer();
            },
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.cover,
              memCacheWidth: 1080,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, __) => ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (_, __, ___) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black45],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentPage ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
