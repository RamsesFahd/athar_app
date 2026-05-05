import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';

class AttractionDetailsScreen extends StatelessWidget {
  final AttractionModel attraction;

  const AttractionDetailsScreen({super.key, required this.attraction});

  static Color _hexColor(String code) {
    final n = code.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$n', radix: 16));
  }

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
    final base = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
    );
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
      '&destination=${attraction.coordinates.latitude}'
      ',${attraction.coordinates.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _share(BuildContext context, bool isAr) {
    final url =
        'https://maps.google.com/?q=${attraction.coordinates.latitude},${attraction.coordinates.longitude}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAr ? 'تم نسخ الرابط' : 'Link copied'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final accent = _hexColor(attraction.categoryColorCode);
    final gallery = attraction.gallery;

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
                  heroTag: 'attraction-${attraction.id}-hero',
                  images: [attraction.mainImage, ...gallery],
                ),

                // ── Content ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Name ────────────────────────────────────────
                      Text(
                        attraction.getName(isAr),
                        style: _nameStyle(isAr, theme),
                      ),

                      const SizedBox(height: 20),

                      // ── Info cards (side by side) ────────────────────
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.schedule_outlined,
                              title: isAr ? 'ساعات العمل' : 'Hours',
                              value: attraction.isAlwaysOpen
                                  ? (isAr ? 'مفتوح 24/7' : 'Always Open')
                                  : attraction.getOpeningHours(isAr),
                              color: accent,
                              isAr: isAr,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.payments_outlined,
                              title: isAr ? 'رسوم الدخول' : 'Entry Fee',
                              value: attraction.entryFee == 0
                                  ? (isAr ? 'مجاني' : 'Free')
                                  : '${attraction.entryFee.toStringAsFixed(0)} SAR',
                              color: attraction.entryFee == 0
                                  ? Colors.green.shade600
                                  : accent,
                              isAr: isAr,
                            ),
                          ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Description ──────────────────────────────────
                      Text(
                        isAr ? 'الوصف' : 'About',
                        style: _sectionTitleStyle(isAr, theme),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        attraction.getDescription(isAr),
                        style: _bodyStyle(isAr, theme),
                      ),


                      // ── Location ─────────────────────────────────────
                      const SizedBox(height: 24),
                      Text(
                        isAr ? 'الموقع' : 'Location',
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
                              attraction.getCity(isAr),
                              style: _bodyStyle(isAr, theme),
                            ),
                          ),
                        ],
                      ),

                      // ── Ticket link ───────────────────────────────────
                      if (attraction.ticketBookingUrl != null) ...[
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => _openUrl(attraction.ticketBookingUrl!),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.confirmation_number_outlined,
                                  color: accent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'احجز تذاكرك هنا' : 'Get tickets here',
                                style: theme.textTheme.bodyMedium?.copyWith(
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
                    _CircleNavButton(
                      icon: Icons.share_outlined,
                      onTap: () => _share(context, isAr),
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
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions_outlined),
                  label: Text(isAr ? 'احصل على الاتجاهات' : 'Get Directions'),
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
        ],
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

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
  final String value;
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
              Text(
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
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value.isNotEmpty ? value : '—',
            style: (isAr
                    ? GoogleFonts.ibmPlexSansArabic()
                    : GoogleFonts.playfairDisplay())
                .copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  final String heroTag;
  final List<String> images;

  const _HeroCarousel({required this.heroTag, required this.images});

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
    return Hero(
      tag: widget.heroTag,
      child: SizedBox(
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
              itemBuilder: (context, index) => Image.network(
                widget.images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            // Bottom gradient — IgnorePointer so swipes reach the PageView
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
            // Dot indicators — IgnorePointer so swipes reach the PageView
            if (widget.images.length > 1)
              Positioned( // <-- اجعل Positioned هي الحاوية الخارجية
                bottom: 16,
                left: 0,
                right: 0,
                child: IgnorePointer( // <-- ضع IgnorePointer بداخلها
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
      ),
    );
  }
}
